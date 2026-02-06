import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/widgets/blog/blog.dart';
import 'package:flutter_blog_2/widgets/bottom_navigation.dart';
import 'package:flutter_blog_2/widgets/home_avatar.dart';
import 'package:flutter_blog_2/widgets/my_drawer.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/';

  static Function(BuildContext context) go = (context) => context.go(routeName);

  static Function(BuildContext context) push = (context) =>
      context.push(routeName);

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // @override
  // void initState() {
  //   // context.read<BlogProvider>().getBlogs(null);
  //   super.initState();
  // }

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
        title: const Text('Home'),
        actions: [HomeAvatar(scaffoldKey: scaffoldKey)],
      ),
      endDrawer: authState.user != null ? const MyDrawer() : null,
      body: content,
      bottomNavigationBar: authState.user != null ? BottomNavigation() : null,
    );
  }
}
