import 'package:calorisense/core/error/exceptions.dart';
import 'package:calorisense/core/error/failures.dart';
import 'package:calorisense/features/auth/data/dataresources/auth_remote_data_source.dart';
import 'package:calorisense/core/common/entities/user.dart';
import 'package:calorisense/features/auth/data/models/user_model.dart';
import 'package:calorisense/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    as sb; // Alias untuk SupabaseClient

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUserData();
      if (user == null) {
        return left(Failure('User not logged in!'));
      }
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.loginWithEmailPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  // Helper method untuk menghindari repetisi try-catch
  Future<Either<Failure, User>> _getUser(Future<User> Function() fn) async {
    try {
      final user = await fn();
      return right(user);
    } on sb.AuthException catch (e) {
      // Tangani AuthException dari Supabase
      return left(Failure(e.message));
    } on ServerException catch (e) {
      // Tangani ServerException dari remoteDataSource
      return left(Failure(e.message));
    } catch (e) {
      // Tangkapan umum lainnya
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    // Implementasi signOut
    try {
      await remoteDataSource.signOut();
      return right(
        null,
      ); // Mengembalikan null (void) di sisi kanan jika berhasil
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } on sb.AuthException catch (e) {
      // Bisa juga ada AuthException saat signOut
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserProfile(User user) async {
    try {
      if (user is! UserModel) {
        return left(
          Failure('Invalid user model type for update. Expected UserModel.'),
        );
      }
      final updatedUserModel = await remoteDataSource.updateUserProfile(
        user as UserModel,
      );
      return right(updatedUserModel);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
