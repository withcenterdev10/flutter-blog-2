import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/screens/auth/sign_up.dart';
import 'package:flutter_blog_2/screens/home_screen.dart';
import 'package:flutter_blog_2/widgets/submit_button.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static const routeName = '/sign_in';

  static Function(BuildContext context) go = (context) => context.go(routeName);

  static Function(BuildContext context) push = (context) =>
      context.push(routeName);

  @override
  State<SignInScreen> createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignInScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool isShowPassword = false;

  void toggleShowPassword() {
    setState(() {
      isShowPassword = !isShowPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select<AuthProvider, bool>(
      (p) => p.getState.loading,
    );
    void onSubmit() async {
      if (formKey.currentState!.validate()) {
        final email = emailController.text;
        final password = passwordController.text;
        String message = "";
        try {
          await context.read<AuthProvider>().signIn(
            email: email,
            password: password,
          );
          message = "Sign in success";
          if (context.mounted) {
            HomeScreen.go(context);
          }
        } catch (error) {
          message = "Sign in failed";
          debugPrint(error.toString());
        } finally {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const SizedBox(height: 20),

                    Text(
                      "Welcome Back",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),

                    const SizedBox(height: 24),

                    // ===== EMAIL =====
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ===== PASSWORD =====
                    TextFormField(
                      controller: passwordController,
                      obscureText: !isShowPassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: toggleShowPassword,
                          icon: Icon(
                            isShowPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // ===== SUBMIT BUTTON =====
                    SizedBox(
                      height: 48,
                      child: SubmitButton(
                        onSubmit: onSubmit,
                        loading: loading,
                        text: "Sign In",
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ===== NAV =====
                    TextButton(
                      onPressed: () {
                        SignUpScreen.push(context);
                      },
                      child: const Text(
                        "Don't have an account yet? Sign Up instead.",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
