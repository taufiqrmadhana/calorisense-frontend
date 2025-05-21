import 'package:calorisense/core/common/widgets/bottom_navbar.dart';
import 'package:calorisense/core/theme/pallete.dart';
import 'package:calorisense/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:calorisense/features/auth/presentation/pages/login_page.dart';
import 'package:calorisense/features/profile/presentation/widgets/profile_header.dart';
import 'package:calorisense/features/profile/presentation/widgets/logout_button.dart';
import 'package:calorisense/features/profile/presentation/widgets/user_profiles_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const ProfilePage());

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial || state is AuthFailure) {
          Navigator.pushAndRemoveUntil(
            context,
            LoginPage.route(),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppPalette.backgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppPalette.white,
          elevation: 0,
          title: Image.asset('assets/images/image.png', height: 150),
          shape: const Border(
            bottom: BorderSide(width: 1, color: AppPalette.borderColor),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileHeader(),
              const SizedBox(height: 32),
              UserProfileDetails(
                email: 'jane.doe@example.com',
                firstName: 'Jane',
                lastName: 'Doe',
                gender: 'Female',
                country: 'Indonesia',
                goal: 'Gain muscle',
                height: 165.0,
                weight: 55.5,
                dateOfBirth: DateTime(1998, 3, 15),
              ),
              const SizedBox(height: 32),
              const LogoutButton(),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavBarWidget(currentIndex: 2),
      ),
    );
  }
}
