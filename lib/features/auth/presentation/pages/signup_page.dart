import 'package:calorisense/core/common/widgets/loader.dart';
import 'package:calorisense/core/theme/pallete.dart';
import 'package:calorisense/core/utils/show_snackbar.dart';
import 'package:calorisense/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:calorisense/features/auth/presentation/pages/login_page.dart';
import 'package:calorisense/features/auth/presentation/widgets/auth_field.dart';
import 'package:calorisense/features/auth/presentation/widgets/auth_button.dart';
import 'package:calorisense/features/auth/presentation/widgets/social_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => SignUpPage());
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppPalette.white,
        centerTitle: true,
        title: Image.asset('assets/images/image.png', height: 170),
        shape: const Border(
          bottom: BorderSide(width: 1, color: AppPalette.borderColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(17, 0, 17, 0),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                MediaQuery.of(context).padding.top,
          ),
          child: IntrinsicHeight(
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthFailure) {
                  showSnackBar(context, state.message);
                }
              },
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Loader();
                }
                return Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Welcome to CaloriSense',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          color: AppPalette.textColor,
                        ),
                      ),
                      const Text(
                        'Track your nutrition journey with ease',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppPalette.textColor,
                        ),
                      ),
                      const SizedBox(height: 30),
                      AuthField(
                        labelText: 'Name',
                        hintText: 'Enter your name',
                        controller: nameController,
                      ),
                      const SizedBox(height: 20),
                      AuthField(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        controller: emailController,
                      ),
                      const SizedBox(height: 20),
                      AuthField(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        controller: passwordController,
                        isObscureText: true,
                      ),
                      const SizedBox(height: 30),
                      AuthButton(
                        title: 'Create Account',
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                              AuthSignUp(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                                name: nameController.text.trim(),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, LoginPage.route());
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account?',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: AppPalette.darkSubTextColor,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(
                                text: ' Sign In',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color: AppPalette.primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SocialAuthOptions(),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
