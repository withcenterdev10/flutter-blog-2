import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/screens/auth/sign_up.dart';
import 'package:flutter_blog_2/screens/home_screen.dart';
import 'package:flutter_blog_2/widgets/auth/sign_up.dart';
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
    final authState = context.watch<AuthProvider>().getState;

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
      appBar: AppBar(title: Text("Sign In")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "email",
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
              TextFormField(
                controller: passwordController,
                obscureText: !isShowPassword,
                decoration: InputDecoration(
                  labelText: "password",
                  suffixIcon: IconButton(
                    onPressed: toggleShowPassword,
                    icon: isShowPassword
                        ? Icon(Icons.visibility)
                        : Icon(Icons.visibility_off),
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSubmit,
                  child: authState.loading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text("Submitting..."),
                          ],
                        )
                      : Text(
                          "Submit",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  SignUpScreen.push(context);
                },
                child: Text("Dont have an account yet? Sign Up instead."),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
