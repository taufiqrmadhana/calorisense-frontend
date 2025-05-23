import 'package:calorisense/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:calorisense/core/usecase/usecase.dart';
import 'package:calorisense/core/common/entities/user.dart';
import 'package:calorisense/features/auth/data/models/user_model.dart';
import 'package:calorisense/features/auth/domain/usecases/current_user.dart';
import 'package:calorisense/features/auth/domain/usecases/user_login.dart';
import 'package:calorisense/features/auth/domain/usecases/user_logout.dart';
import 'package:calorisense/features/auth/domain/usecases/user_signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignup _userSignup;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  final AppUserCubit _appUserCubit;
  final UserLogout _userLogout; // Tambahkan UserLogout

  AuthBloc({
    required UserSignup userSignUp,
    required UserLogin userLogin,
    required CurrentUser currentUser,
    required AppUserCubit appUserCubit,
    required UserLogout userLogout, // Tambahkan UserLogout
  }) : _userSignup = userSignUp,
       _userLogin = userLogin,
       _currentUser = currentUser,
       _appUserCubit = appUserCubit,
       _userLogout = userLogout, // Tambahkan UserLogout
       super(AuthInitial()) {
    // HAPUS BARIS INI: on<AuthEvent>((_, emit) => (AuthLoading()));

    // Tambahkan handler untuk AuthLoading di setiap method jika diperlukan
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogin>(_onAuthLogin);
    on<AuthIsUserLoggedIn>(_isUserLoggedIn);
    on<AuthLogout>(_onAuthLogout); // Tambahkan handler AuthLogout
  }

  void _isUserLoggedIn(
    AuthIsUserLoggedIn event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading()); // Emit loading di sini
    final res = await _currentUser(NoParams());

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) => _emitAuthSuccess(r, emit),
    );
  }

  void _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading()); // Emit loading di sini
    final res = await _userSignup(
      UserSignUpParams(event.email, event.password, event.name),
    );
    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading()); // Emit loading di sini
    final res = await _userLogin(UserLoginParams(event.email, event.password));

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) => _emitAuthSuccess(r, emit),
    );
  }

  void _onAuthLogout(AuthLogout event, Emitter<AuthState> emit) async {
    // Method untuk Logout
    emit(AuthLoading());
    final res = await _userLogout(NoParams());
    res.fold((failure) => emit(AuthFailure(failure.message)), (_) {
      _appUserCubit.updateUser(null); // Reset user di AppUserCubit
      emit(
        AuthInitial(),
      ); // Kembali ke state initial atau state yang sesuai setelah logout
    });
  }

  void _emitAuthSuccess(User user, Emitter<AuthState> emit) {
    // PENTING: Lakukan casting yang aman di sini.
    // Kita tahu user yang datang dari repository adalah UserModel.
    if (user is UserModel) {
      _appUserCubit.updateUser(user); // Sekarang akan menerima UserModel
      emit(AuthSuccess(user));
    } else {
      // Ini adalah fallback, seharusnya tidak terjadi jika alur repository benar
      emit(
        AuthFailure(
          "Internal error: User type mismatch after successful auth.",
        ),
      );
    }
  }
}
