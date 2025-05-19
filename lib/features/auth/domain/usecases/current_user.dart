import 'package:calorisense/core/error/failures.dart';
import 'package:calorisense/core/usecase/usecase.dart';
import 'package:calorisense/core/common/entities/user.dart';
import 'package:calorisense/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class CurrentUser implements Usecase<User, NoParams> {
  final AuthRepository authRepository;
  CurrentUser(this.authRepository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await authRepository.currentUser();
  }
}
