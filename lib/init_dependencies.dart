import 'package:calorisense/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:calorisense/features/auth/data/dataresources/auth_remote_data_source.dart';
import 'package:calorisense/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:calorisense/features/auth/domain/repository/auth_repository.dart';
import 'package:calorisense/features/auth/domain/usecases/current_user.dart';
import 'package:calorisense/features/auth/domain/usecases/update_user_profile.dart';
import 'package:calorisense/features/auth/domain/usecases/user_login.dart';
import 'package:calorisense/features/auth/domain/usecases/user_logout.dart';
import 'package:calorisense/features/auth/domain/usecases/user_signup.dart';
import 'package:calorisense/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:calorisense/core/secrets/app_secrets.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  serviceLocator.registerLazySingleton(() => supabase.client);

  // core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
}

void _initAuth() {
  serviceLocator
    //DataSource
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(serviceLocator()),
    )
    //Repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator()),
    )
    //UseCases
    ..registerFactory(() => UserSignup(serviceLocator()))
    ..registerFactory(() => UserLogin(serviceLocator()))
    ..registerFactory(() => CurrentUser(serviceLocator()))
    ..registerFactory(() => UserLogout(serviceLocator()))
    ..registerFactory(() => UpdateUserProfile(serviceLocator()))
    //Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
        userLogout: serviceLocator(),
      ),
    );
}
