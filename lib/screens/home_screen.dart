import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/widgets/blog/blog.dart';
import 'package:flutter_blog_2/widgets/home_avatar.dart';
import 'package:flutter_blog_2/widgets/my_drawer.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final blogsState = context.watch<BlogProvider>().getBlogsState;
    final authState = context.watch<AuthProvider>().getState;

    Widget content = Center(
      child: const SizedBox(
        width: 15,
        height: 15,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );

    if (blogsState.blogs.isNotEmpty && !blogsState.loading) {
      content = ListView.builder(
        itemCount: blogsState.blogs.length,
        itemBuilder: (BuildContext context, int index) {
          return Blog(blog: blogsState.blogs[index]);
        },
      );
    }

    if (blogsState.blogs.isEmpty && !blogsState.loading) {
      content = Center(child: Text("No blogs found"));
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [HomeAvatar(scaffoldKey: scaffoldKey)],
      ),
      endDrawer: authState.user != null ? const MyDrawer() : null,
      body: content,
    );
  }
}
