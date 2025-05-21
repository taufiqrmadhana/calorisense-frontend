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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
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
      routes: {
        '/home': (context) => const HomePage(),
        '/chat': (context) => const ChatPage(),
        '/profile': (context) => const ProfilePage(),
      },
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            return const HomePage();
          } else if (state is AuthFailure || state is AuthInitial) {
            return const LoginPage();
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
