import 'package:flutter/material.dart';
import 'package:flutter_blog_2/widgets/blog/edit_blog.dart';
import 'package:flutter_blog_2/widgets/unfocus_close_keyboard.dart';
import 'package:go_router/go_router.dart';

class EditBlogScreen extends StatefulWidget {
  const EditBlogScreen({super.key});

  static const routeName = '/edit_blog';
  static const callRouteName = '/$routeName';

  static Function(BuildContext context) go = (context) => context.go(routeName);

  static Function(BuildContext context) push = (context) =>
      context.push(routeName);

  @override
  State<EditBlogScreen> createState() {
    return _EditBlogScreenState();
  }
}

class _EditBlogScreenState extends State<EditBlogScreen> {
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
    return UnfocusCloseKeyboard(
      child: Scaffold(appBar: AppBar(), body: EditBlog()),
    );
  }
}
