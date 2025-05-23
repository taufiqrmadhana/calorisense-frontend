part of 'app_user_cubit.dart';

@immutable
sealed class AppUserState {}

final class AppUserInitial extends AppUserState {}

final class AppUserLoggedIn extends AppUserState {
  final UserModel user; // <-- UBAH TIPE DI SINI menjadi UserModel
  AppUserLoggedIn(this.user);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppUserLoggedIn &&
        other.user == user; // Pastikan perbandingan equality untuk User model
  }

  @override
  int get hashCode => user.hashCode;
}
