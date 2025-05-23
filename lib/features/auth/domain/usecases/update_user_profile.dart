// features/auth/domain/usecases/update_user_profile.dart
import 'package:calorisense/core/error/failures.dart';
import 'package:calorisense/core/usecase/usecase.dart';
import 'package:calorisense/core/common/entities/user.dart';
import 'package:calorisense/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateUserProfile implements Usecase<User, User> {
  final AuthRepository authRepository;

  UpdateUserProfile(this.authRepository);

  @override
  Future<Either<Failure, User>> call(User user) async {
    return await authRepository.updateUserProfile(user);
  }
}
