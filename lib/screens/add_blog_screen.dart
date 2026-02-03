import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class AddBlogScreen extends StatefulWidget {
  const AddBlogScreen({super.key});

  static const routeName = '/add_blog';
  static const routeNameNested = '/blogs/add_blog';

  static Function(BuildContext context) go = (context) =>
      context.go(routeNameNested);

  static Function(BuildContext context) push = (context) =>
      context.push(routeName);

  @override
  State<AddBlogScreen> createState() {
    return _AddBlogScreenState();
  }
}

class _AddBlogScreenState extends State<AddBlogScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
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
    final authState = context.watch<Auth>().getState;

    void onSubmit() async {
      if (formKey.currentState!.validate()) {
        String message = "";
        try {
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
            Text("Add blog", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
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
          ],
        ),
      ),
    );
  }
}
