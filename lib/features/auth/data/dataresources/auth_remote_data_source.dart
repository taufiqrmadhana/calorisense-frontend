import 'package:calorisense/core/error/exceptions.dart';
import 'package:calorisense/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Session? get currentUserSession;

  Future<UserModel> signUpWithEmailPassword({
    required String name, // Ini adalah username
    required String email,
    required String password,
  });
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });
  Future<UserModel?> getCurrentUserData();
  Future<void> signOut(); // Tambahkan signOut
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
        throw const ServerException('User is null after login.');
      }

      final userId = response.user!.id;
      final authEmail = response.user!.email!;

      // Ambil data dari tabel 'users'
      final userDataMap =
          await supabaseClient
              .from('users') // <--- GANTI KE 'users'
              .select()
              .eq('id', userId)
              .maybeSingle(); // Gunakan maybeSingle untuk handle jika data tidak ada

      if (userDataMap == null) {
        // Ini idealnya tidak terjadi jika user sudah signup dengan benar
        // dan memiliki entri di tabel 'users'.
        // Sebagai fallback, buat UserModel dengan data minimal dari auth.
        print(
          'WARNING: User data not found in "users" table for id: $userId. Using auth data as fallback.',
        );
        return UserModel(
          id: userId,
          email: authEmail,
          name:
              response.user!.userMetadata?['name'] ??
              email.split('@')[0], // Ambil dari metadata jika ada
          // Field lain akan null
        );
      }
      // Buat UserModel dari data tabel 'users', pastikan email dari auth yang dipakai.
      return UserModel.fromJson(userDataMap).copyWith(email: authEmail);
    } on AuthException catch (e) {
      // Tangani AuthException secara spesifik
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name, // Ini adalah username
    required String email,
    required String password,
  }) async {
    try {
      // 1. Daftarkan pengguna ke Supabase Auth
      final authResponse = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        // data: {'name': name}, // Mengirim 'name' ke user_metadata di auth.users
        // Ini opsional jika Anda hanya mengandalkan kolom 'name' di tabel 'users'
      );

      if (authResponse.user == null) {
        throw const ServerException('User is null after Supabase auth signUp.');
      }

      final userId = authResponse.user!.id;
      final userEmail = authResponse.user!.email!;

      // 2. Siapkan data untuk dimasukkan ke tabel 'public.users'
      final UserModel userToInsert = UserModel(
        id: userId,
        email: userEmail,
        name: name, // Username dari input
        // Field lain (firstName, lastName, dll.) akan null secara default
      );

      // 3. Masukkan data ke tabel 'public.users'
      final insertedUserResponse =
          await supabaseClient
              .from('users') // <--- GANTI KE 'users'
              .insert(
                userToInsert.toJsonForUsersTableInsert(),
              ) // Gunakan method toJson yang sesuai
              .select()
              .single(); // Asumsi hanya satu baris yang diinsert dan kita mau data itu

      return UserModel.fromJson(insertedUserResponse);
    } on AuthException catch (e) {
      // Tangani AuthException
      if (e.message.toLowerCase().contains('user already exists') ||
          e.message.toLowerCase().contains('already registered')) {
        throw ServerException('User with this email already exists.');
      }
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUserSession != null) {
        final userId = currentUserSession!.user.id;
        final authEmail = currentUserSession!.user.email;

        final userDataMap =
            await supabaseClient
                .from('users') // <--- GANTI KE 'users'
                .select()
                .eq('id', userId)
                .maybeSingle(); // Gunakan maybeSingle untuk penanganan yang lebih aman

        if (userDataMap == null) {
          // Jika data tidak ditemukan di 'users', mungkin user hanya ada di auth
          // Kembalikan UserModel minimal atau null
          print(
            'WARNING: User data not found in "users" table for id: $userId. Using auth data as fallback.',
          );
          if (authEmail != null) {
            return UserModel(
              id: userId,
              email: authEmail,
              name:
                  currentUserSession!.user.userMetadata?['name'] ??
                  authEmail.split('@')[0],
            );
          }
          return null;
        }
        return UserModel.fromJson(userDataMap).copyWith(email: authEmail);
      }
      return null;
    } catch (e) {
      // Sebaiknya tidak melempar ServerException di sini jika ingin flow normal mengembalikan null
      print("Error in getCurrentUserData: $e");
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    // Implementasi signOut
    try {
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
