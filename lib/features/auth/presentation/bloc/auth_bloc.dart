import 'package:calorisense/features/auth/domain/entities/user.dart';
import 'package:calorisense/features/auth/domain/usecases/user_login.dart';
import 'package:calorisense/features/auth/domain/usecases/user_signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignup _userSignup;
  final UserLogin _userLogin;

  AuthBloc({required UserSignup userSignUp, required UserLogin userLogin})
    : _userSignup = userSignUp,
      _userLogin = userLogin,
      super(AuthInitial()) {
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogin>(_onAuthLogin);
  }

  void _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userSignup(
      UserSignUpParams(event.email, event.password, event.name),
    );
    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  void _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final res = await _userLogin(UserLoginParams(event.email, event.password));

    res.fold((l) => emit(AuthFailure(l.message)), (r) => emit(AuthSuccess(r)));
  }
}
