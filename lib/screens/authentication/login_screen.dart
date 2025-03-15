import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studystack/blocs/authentication/auth_bloc.dart';
import 'package:studystack/blocs/authentication/auth_event.dart';
import 'package:studystack/blocs/authentication/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showPassword = false;

  bool isValidEmail(String email) {
    final emailPattern = r'^(\d{4})([a-z]+)(\d{3})@nitjsr\.ac\.in$';
    final regExp = RegExp(emailPattern, caseSensitive: false);

    if (regExp.hasMatch(email)) {
      final match = regExp.firstMatch(email);
      if (match != null) {
        final year = int.parse(match.group(1)!);
        return year <= 2025;
      }
    }
    return false;
  }

  bool isValidPassword(String password) {
    final passwordPattern = r'^.+$';
    return RegExp(passwordPattern).hasMatch(password);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationFailure) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error)));
        }
        if (state is AuthenticationAuthenticated) {
          Navigator.pushReplacementNamed(context, '/');
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/placeholder.jpg',
                    height: 200,
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    'Welcome to StudyStack',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Your one-stop solution for organized class notes and resources.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
                    builder: (context, state) {
                      if (state is AuthenticationLoading) {
                        return const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        );
                      } else {
                        return GestureDetector(
                          onTap: () {
                            context.read<AuthenticationBloc>().add(
                                  AuthenticationGoogleSignInRequested(),
                                );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Brand(Brands
                                  .google), // Assuming you have this widget
                              const SizedBox(width: 10),
                              Text(
                                'Continue with Google',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'or continue with',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email address',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        icon: const Icon(Icons.visibility)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Forgot Password ?',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.end,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
                    builder: (context, state) {
                      if (state is AuthenticationLoading) {
                        return OutlinedButton(
                          onPressed: null,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.grey[900],
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      } else {
                        return OutlinedButton(
                          onPressed: () {
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();

                            if (!isValidEmail(email)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Invalid email. Ensure it follows the NITJSR format')),
                              );
                              return;
                            }

                            if (!isValidPassword(password)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Password must be at least 8 characters long and include upper and lowercase letters and a number.')),
                              );
                              return;
                            }

                            context.read<AuthenticationBloc>().add(
                                  AuthenticationLoginRequested(
                                      email: email, password: password),
                                );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.grey[900],
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/sign-up'),
                    child: Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
