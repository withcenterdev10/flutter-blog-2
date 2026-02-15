import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/widgets/auth/sign_in.dart';
import 'package:flutter_blog_2/widgets/submit_button.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  static const routeName = '/sign_up';

  static Function(BuildContext context) go = (context) => context.go(routeName);

  static Function(BuildContext context) push = (context) =>
      context.push(routeName);

  @override
  State<SignUp> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUp> {
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

  void showSignInModal() {
    Navigator.of(context).pop();
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => const SignIn(),
    );
  }

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
            Navigator.of(context).pop();
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

    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: AlignmentGeometry.centerRight,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.close),
              ),
            ),
            const SizedBox(height: 30),
            Text("Sign Up", style: Theme.of(context).textTheme.headlineSmall),
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
              child: SubmitButton(onSubmit: onSubmit, loading: loading),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: showSignInModal,
              child: Text("Already had an account? Sign In instead."),
            ),
          ],
        ),
      ),
    );
  }
}
