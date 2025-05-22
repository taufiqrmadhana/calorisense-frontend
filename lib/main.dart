import 'package:calorisense/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:calorisense/core/theme/theme.dart';
import 'package:calorisense/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:calorisense/features/auth/presentation/pages/login_page.dart';
import 'package:calorisense/features/chat/presentation/pages/chat_page.dart';
import 'package:calorisense/features/home/presentation/pages/home_page.dart';
import 'package:calorisense/features/profile/presentation/pages/profile_page.dart';
import 'package:calorisense/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 1. Definisikan RouteObserver secara global
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AppUserCubit>()),
        BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Memastikan event dikirim setelah frame pertama selesai dibangun
    // untuk menghindari error jika context belum sepenuhnya siap.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Pastikan widget masih mounted
        context.read<AuthBloc>().add(AuthIsUserLoggedIn());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CaloriSense',
      theme: AppTheme.lightThemeMode,
      // 2. Tambahkan routeObserver ke navigatorObservers
      navigatorObservers: [routeObserver],
      // initialRoute dihapus karena home dengan BlocSelector menanganinya.
      routes: {
        // Rute bernama ini akan digunakan untuk navigasi setelah halaman awal ditentukan.
        // Pastikan HomePage yang dirujuk di sini adalah instance yang sama
        // atau memiliki cara untuk berinteraksi dengan RouteAware jika diperlukan.
        // Biasanya, jika HomePage adalah halaman awal, RouteAware akan bekerja.
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(), // Tambahkan rute login jika belum ada
        '/chat': (context) => const ChatPage(),
        '/profile': (context) => const ProfilePage(),
      },
      home: BlocSelector<AppUserCubit, AppUserState, bool>(
        selector: (state) {
          return state is AppUserLoggedIn;
        },
        builder: (context, isLoggedIn) {
          if (isLoggedIn) {
            // Jika pengguna login, HomePage akan menjadi halaman awal.
            // RouteAware pada HomePage akan berfungsi.
            return const HomePage();
          }
          // Jika tidak, LoginPage akan ditampilkan.
          return const LoginPage();
        },
      ),
    );
  }
}