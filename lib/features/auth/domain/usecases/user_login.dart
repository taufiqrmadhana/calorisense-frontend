import 'package:calorisense/core/error/failures.dart';
import 'package:calorisense/core/usecase/usecase.dart';
import 'package:calorisense/core/common/entities/user.dart';
import 'package:calorisense/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserLogin implements Usecase<User, UserLoginParams> {
  final AuthRepository authRepository;
  UserLogin(this.authRepository);

  @override
  Future<Either<Failure, User>> call(UserLoginParams params) async {
    return authRepository.loginWithEmailPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class UserLoginParams {
  final String email;
  final String password;

  UserLoginParams(this.email, this.password);
}
