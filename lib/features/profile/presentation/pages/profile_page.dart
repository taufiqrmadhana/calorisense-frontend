import 'package:calorisense/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:calorisense/core/common/widgets/bottom_navbar.dart';
import 'package:calorisense/core/theme/pallete.dart';
import 'package:calorisense/features/auth/data/models/user_model.dart';
import 'package:calorisense/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:calorisense/features/auth/presentation/pages/login_page.dart';
import 'package:calorisense/features/profile/widgets/logout_button.dart';
import 'package:calorisense/features/profile/widgets/profile_header.dart';
import 'package:calorisense/features/profile/widgets/profile_edit_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:calorisense/features/auth/domain/usecases/update_user_profile.dart';
import 'package:calorisense/init_dependencies.dart';

class ProfilePage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const ProfilePage());

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _countryController;
  late TextEditingController _genderController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _goalController;

  bool _isLoading = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    _countryController = TextEditingController();
    _genderController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _goalController = TextEditingController();

    _loadUserData();
  }

  void _loadUserData() {
    final appUserState = context.read<AppUserCubit>().state;
    if (appUserState is AppUserLoggedIn) {
      _currentUser = appUserState.user;
    } else {
      _currentUser = null;
    }

    if (_currentUser != null) {
      _firstNameController.text = _currentUser!.firstName ?? '-';
      _lastNameController.text = _currentUser!.lastName ?? '-';
      _dateOfBirthController.text =
          _currentUser!.dateOfBirth != null
              ? DateFormat('yyyy-MM-dd').format(_currentUser!.dateOfBirth!)
              : '-';
      _countryController.text = _currentUser!.country ?? '-';
      _genderController.text = _currentUser!.gender ?? '-';
      _heightController.text = _currentUser!.height?.toString() ?? '-';
      _weightController.text = _currentUser!.weight?.toString() ?? '-';
      _goalController.text = _currentUser!.goal ?? '-';
    } else {
      _firstNameController.text = '-';
      _lastNameController.text = '-';
      _dateOfBirthController.text = '-';
      _countryController.text = '-';
      _genderController.text = '-';
      _heightController.text = '-';
      _weightController.text = '-';
      _goalController.text = '-';
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final updatedUser = UserModel(
      id: _currentUser!.id,
      email: _currentUser!.email,
      name: _currentUser!.name,
      firstName:
          _firstNameController.text != '-' ? _firstNameController.text : null,
      lastName:
          _lastNameController.text != '-' ? _lastNameController.text : null,
      dateOfBirth:
          _dateOfBirthController.text != '-'
              ? DateTime.tryParse(_dateOfBirthController.text)
              : null,
      country: _countryController.text != '-' ? _countryController.text : null,
      gender: _genderController.text != '-' ? _genderController.text : null,
      height:
          _heightController.text != '-'
              ? double.tryParse(_heightController.text)
              : null,
      weight:
          _weightController.text != '-'
              ? double.tryParse(_weightController.text)
              : null,
      goal: _goalController.text != '-' ? _goalController.text : null,
      createdAt: _currentUser!.createdAt,
      updatedAt: DateTime.now(),
    );

    final result = await serviceLocator<UpdateUserProfile>().call(updatedUser);

    setState(() {
      _isLoading = false;
    });

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (successUser) {
        context.read<AppUserCubit>().updateUser(successUser as UserModel);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUserData();
      },
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _countryController.dispose();
    _genderController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalController.dispose();
    super.dispose();
  }

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
        } else if (state is AuthSuccess) {
          _loadUserData();
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
        body:
            _currentUser == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileHeader(
                          userName: _currentUser!.name,
                          userEmail: _currentUser!.email,
                        ),
                        const SizedBox(height: 32),
                        ProfileEditField(
                          label: 'Email',
                          value: _currentUser!.email,
                          readOnly: true,
                        ),
                        ProfileEditField(
                          label: 'Username',
                          value: _currentUser!.name,
                          readOnly: true,
                        ),
                        ProfileEditField(
                          label: 'First Name',
                          controller: _firstNameController,
                          hintText: 'Enter your first name',
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value == '-') {
                              return null; // Boleh null atau '-'
                            }
                            return null;
                          },
                        ),
                        ProfileEditField(
                          label: 'Last Name',
                          controller: _lastNameController,
                          hintText: 'Enter your last name',
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value == '-') {
                              return null;
                            }
                            return null;
                          },
                        ),
                        ProfileEditField(
                          label: 'Date of Birth (YYYY-MM-DD)',
                          controller: _dateOfBirthController,
                          hintText: 'e.g., 1990-01-01',
                          keyboardType: TextInputType.datetime,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value == '-') {
                              return null;
                            }
                            try {
                              DateFormat('yyyy-MM-dd').parseStrict(value);
                            } catch (e) {
                              return 'Invalid date format (YYYY-MM-DD)';
                            }
                            return null;
                          },
                        ),
                        ProfileEditField(
                          label: 'Country',
                          controller: _countryController,
                          hintText: 'Enter your country',
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value == '-') {
                              return null;
                            }
                            return null;
                          },
                        ),
                        ProfileEditField(
                          label: 'Gender',
                          controller: _genderController,
                          hintText: 'e.g., Male, Female, Other',
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value == '-') {
                              return null;
                            }
                            return null;
                          },
                        ),
                        ProfileEditField(
                          label: 'Height (cm)',
                          controller: _heightController,
                          hintText: 'e.g., 170.5',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value == '-') {
                              return null;
                            }
                            if (double.tryParse(value) == null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                        ProfileEditField(
                          label: 'Weight (kg)',
                          controller: _weightController,
                          hintText: 'e.g., 65.2',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value == '-') {
                              return null;
                            }
                            if (double.tryParse(value) == null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                        ProfileEditField(
                          label: 'Goal',
                          controller: _goalController,
                          hintText: 'e.g., Lose weight, Gain muscle',
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value == '-') {
                              return null;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    _isLoading
                                        ? null
                                        : _updateProfile, // Disable button when loading
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppPalette.primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          height: 24,
                                          width: 24, 
                                          child: CircularProgressIndicator(
                                            color: AppPalette.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text(
                                          'Update Profile',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: AppPalette.white,
                                          ),
                                        ),
                              ),
                            ),
                            const SizedBox(width: 16), // Space between buttons
                            Expanded(
                              child:
                                  LogoutButton(), // LogoutButton will now take up equal space
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        bottomNavigationBar: const BottomNavBarWidget(currentIndex: 2),
      ),
    );
  }
}
