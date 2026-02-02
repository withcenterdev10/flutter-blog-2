import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/widgets/auth/sign_up.dart';
import 'package:provider/provider.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignIn> {
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
  void showSignUpModal() {
    Navigator.of(context).pop();
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => const SignUp(),
    );
  }

  void toggleShowPassword() {
    setState(() {
      isShowPassword = !isShowPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<Auth>().getState;

    void onSubmit() async {
      if (formKey.currentState!.validate()) {
        final email = emailController.text;
        final password = passwordController.text;
        String message = "";
        try {
          await context.read<Auth>().signIn(email: email, password: password);
          message = "Sign in success";
          if (context.mounted) {
            Navigator.of(context).pop();
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
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
            Text("Sign In", style: Theme.of(context).textTheme.headlineSmall),
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
              onPressed: showSignUpModal,
              child: Text("Dont have an account yet? Sign Up instead."),
            ),
          ],
        ),
      ),
    );
  }
}
