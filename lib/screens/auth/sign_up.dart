import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/screens/auth/sign_in.dart';
import 'package:flutter_blog_2/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const routeName = '/sign_up';

  static Function(BuildContext context) go = (context) => context.go(routeName);

  static Function(BuildContext context) push = (context) =>
      context.push(routeName);

  @override
  State<SignUpScreen> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUpScreen> {
  bool isShowPassword = false;

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

  void toggleShowPassword() {
    setState(() {
      isShowPassword = !isShowPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    void onSubmit() async {
      if (formKey.currentState!.validate()) {
        final name = nameController.text;
        final email = emailController.text;
        final password = passwordController.text;
        String message = "";
        try {
          await context.read<AuthProvider>().signUp(
            email: email,
            password: password,
            displayName: name,
          );
          message = "Sign up success";

          if (context.mounted) {
            HomeScreen.go(context);
          }
        } catch (error) {
          message = "Sign up failed";
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

    final authState = context.watch<AuthProvider>().getState;

    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }

                  return null;
                },
              ),

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
                  SignInScreen.push(context);
                },
                child: Text("Already had an account? Sign In instead."),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
