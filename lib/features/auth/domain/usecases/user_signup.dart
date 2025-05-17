import 'package:calorisense/core/error/failures.dart';
import 'package:calorisense/core/usecase/usecase.dart';
import 'package:calorisense/features/auth/domain/entities/user.dart';
import 'package:calorisense/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserSignup implements Usecase<User, UserSignUpParams> {
  final AuthRepository authRepository;
  UserSignup(this.authRepository);

  @override
  Future<Either<Failure, User>> call(UserSignUpParams params) async {
    return authRepository.signUpWithEmailPassword(
      name: params.name,
      email: params.email,
      password: params.password,
    );
  }
}

class UserSignUpParams {
  final String email;
  final String password;
  final String name;

  const UserSignUpParams(this.email, this.password, this.name);
}
