import 'package:calorisense/core/error/failures.dart';
import 'package:calorisense/core/usecase/usecase.dart';
import 'package:calorisense/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserLogout implements Usecase<void, NoParams> {
  final AuthRepository authRepository;
  UserLogout(this.authRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return authRepository.signOut();
  }
}
