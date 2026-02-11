import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/providers/screen_provider.dart';
import 'package:flutter_blog_2/screens/blogs_screen.dart';
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

  bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  void handleNavigationClick(BuildContext context, int screenIndex) {
    context.read<ScreenProvider>().setScreen(screenIndex);
    final authState = context.read<AuthProvider>().getState;
    if (screenIndex == 1) {
      BlogsScreen.go(context);
      context.read<BlogProvider>().getBlogs(authState.user?.id);
    }
    if (screenIndex == 0) {
      HomeScreen.go(context);
      context.read<BlogProvider>().getBlogs(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final blogsState = context.watch<BlogProvider>().getBlogsState;
    final authState = context.watch<AuthProvider>().getState;

    Widget content = const SizedBox(
      width: 15,
      height: 15,
      child: CircularProgressIndicator(strokeWidth: 2),
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
      content = Text("No blogs found");
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        actions: [const SizedBox()],
        title: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Row(
              children: [
                GestureDetector(
                  child: Text("Home"),
                  onTap: () {
                    handleNavigationClick(context, 0);
                  },
                ),
                const Spacer(),
                if (isDesktop(context))
                  TextButton(
                    onPressed: () {
                      handleNavigationClick(context, 1);
                    },
                    child: const Text("My Blogs"),
                  ),
                HomeAvatar(scaffoldKey: scaffoldKey),
              ],
            ),
          ),
        ),

        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1),
        ),
      ),

      endDrawer: authState.user != null ? const MyDrawer() : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: content,
          ),
        ),
      ),
      bottomNavigationBar: authState.user != null && !isDesktop(context)
          ? BottomNavigation()
          : null,
    );
  }
}
