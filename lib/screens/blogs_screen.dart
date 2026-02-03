import 'package:flutter/material.dart';
import 'package:flutter_blog_2/screens/add_blog_screen.dart';
import 'package:go_router/go_router.dart';

class Blogs extends StatefulWidget {
  const Blogs({super.key});

  static const routeName = '/blogs';

  static Function(BuildContext context) go = (context) => context.go(routeName);

  static Function(BuildContext context) push = (context) =>
      context.push(routeName);

  @override
  State<Blogs> createState() {
    return _BlogsState();
  }
}

class _BlogsState extends State<Blogs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My blogs')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                AddBlogScreen.go(context);
              },
              child: Text("Add blog"),
            ),
          ],
        ),
      ),
    );
  }
}
