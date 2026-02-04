import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/screens/add_blog_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import "package:flutter_blog_2/widgets/blog/blog.dart";
import "package:flutter_blog_2/temp.dart";

class BlogsScreen extends StatefulWidget {
  const BlogsScreen({super.key});

  static const routeName = '/blog-screen';
  static const callRouteName = "/$routeName";

  static Function(BuildContext context) go = (context) => context.go(routeName);

  static Function(BuildContext context) push = (context) =>
      context.push(routeName);

  @override
  State<BlogsScreen> createState() {
    return _BlogsScreenState();
  }
}

class _BlogsScreenState extends State<BlogsScreen> {
  @override
  Widget build(BuildContext context) {
    final blogsState = context.watch<BlogProvider>().getBlogsState;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My blogs'),
        actions: [
          IconButton(
            onPressed: () {
              AddBlogScreen.go(context);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: blogsState.blogs.length,
        itemBuilder: (BuildContext context, int index) {
          return Blog(blog: blogsState.blogs[index]);
        },
      ),
    );
  }
}
