import 'package:flutter/material.dart';
import 'package:flutter_blog_2/widgets/blog/add_blog.dart';
import 'package:go_router/go_router.dart';

class AddBlogScreen extends StatefulWidget {
  const AddBlogScreen({super.key});

  static const routeName = '/add_blog';
  static const callRouteName = '/$routeName';

  static Function(BuildContext context) go = (context) => context.go(routeName);

  static Function(BuildContext context) push = (context) =>
      context.push(routeName);

  @override
  State<AddBlogScreen> createState() {
    return _AddBlogScreenState();
  }
}

class _AddBlogScreenState extends State<AddBlogScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: AddBlog());
  }
}
