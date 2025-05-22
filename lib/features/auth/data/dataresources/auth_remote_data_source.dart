import 'package:calorisense/core/error/exceptions.dart';
import 'package:calorisense/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Session? get currentUserSession;

  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });
  Future<UserModel?> getCurrentUserData();
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;

  @override
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const ServerException('The user is null');
      }

      final userId = response.user!.id;

      final userData =
          await supabaseClient
              .from('profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();

      if (userData != null) {
        final profileModel = UserModel.fromJson(userData);
        return profileModel.copyWith(email: response.user!.email);
      } else {
        // fallback only if profile is truly missing
        final username = email.split('@')[0];
        return UserModel(id: userId, email: email, name: username);
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      if (response.user == null) {
        throw const ServerException('The user is null');
      }

      // Create profile record with the provided name
      final userId = response.user!.id;
      await supabaseClient.from('profiles').upsert({
        'id': userId,
        'name': name,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Return user with the correct name
      return UserModel.fromJson(response.user!.toJson()).copyWith(name: name);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      final session = supabaseClient.auth.currentSession;
      if (session != null) {
        final userId = session.user.id;
        final email = session.user.email;

        try {
          final userData =
              await supabaseClient
                  .from('profiles')
                  .select()
                  .eq('id', userId)
                  .single();

          final profileModel = UserModel.fromJson(userData);

          if (profileModel.name.isEmpty) {
            final username = email?.split('@')[0] ?? 'User';
            return profileModel.copyWith(email: email, name: username);
          }

          return profileModel.copyWith(email: email);
        } catch (e) {
          final username = email?.split('@')[0] ?? 'User';
          return UserModel(id: userId, email: email ?? '', name: username);
        }
      }
      return null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
