import 'package:flutter/material.dart';
import 'package:flutter_blog_2/models/blog_model.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/screens/add_blog_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import "package:flutter_blog_2/widgets/blog/blog.dart";

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
    final blogsState = context.watch<BlogProviders>().getBlogsState;
    return Scaffold(
      appBar: AppBar(title: const Text('My blogs')),
      body: Center(
        child: Column(
          mainAxisSize: blogsState.loading
              ? MainAxisSize.min
              : MainAxisSize.max,
          children: [
            blogsState.loading
                ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : ElevatedButton(
                    onPressed: () {
                      AddBlogScreen.go(context);
                    },
                    child: Text("Add blog"),
                  ),
            const SizedBox(height: 5),
            ...blogsState.blogs.map((b) {
              return Blog(blog: b);
            }),
          ],
        ),
      ),
    );
  }
}
