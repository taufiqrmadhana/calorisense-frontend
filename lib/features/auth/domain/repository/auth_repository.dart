import 'package:calorisense/core/error/failures.dart';
import 'package:calorisense/core/common/entities/user.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> currentUser();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, User>> updateUserProfile(User user);
}
