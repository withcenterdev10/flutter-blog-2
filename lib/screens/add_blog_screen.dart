import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/widgets/blog/add_blog.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class AddBlogScreen extends StatefulWidget {
  const AddBlogScreen({super.key});

  static const routeName = 'add_blog';
  static const callRouteName = '/$routeName';

  static Function(BuildContext context) go = (context) =>
      context.go(callRouteName);

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

    return Scaffold(
      appBar: AppBar(title: const Text('Add new blog')),
      body: Center(child: Column(children: [AddBlog()])),
    );
  }
}
