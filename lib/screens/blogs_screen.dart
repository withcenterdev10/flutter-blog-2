import 'package:flutter/material.dart';
import 'package:flutter_blog_2/models/blogs_model.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/screens/add_blog_screen.dart';
import 'package:flutter_blog_2/widgets/bottom_navigation.dart';
import 'package:flutter_blog_2/widgets/layout/appbar.dart';
import 'package:flutter_blog_2/widgets/my_drawer.dart';
import 'package:flutter_blog_2/widgets/spinner.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import "package:flutter_blog_2/widgets/blog/blog.dart";
import 'package:supabase_flutter/supabase_flutter.dart';

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
  bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  @override
  Widget build(BuildContext context) {
    final blogsState = context.select<BlogProvider, BlogsModel>(
      (p) => p.getBlogsState,
    );
    final userAuthenticated = context.select<AuthProvider, User?>(
      (p) => p.getState.user,
    );
    final scaffoldKey = GlobalKey<ScaffoldState>();
    bool isDesktop = MediaQuery.of(context).size.width >= 900;

    Widget content = Align(
      alignment: AlignmentGeometry.center,
      child: Spinner(),
    );

    if (blogsState.blogs.isNotEmpty && !blogsState.loading) {
      content = Selector<BlogProvider, BlogsModel>(
        selector: (_, provider) => provider.getBlogsState,
        builder: (_, value, _) {
          return ListView.builder(
            itemCount: value.blogs.length,
            itemBuilder: (BuildContext context, int index) {
              return Blog(blog: value.blogs[index]);
            },
          );
        },
      );
    }

    if (blogsState.blogs.isEmpty && !blogsState.loading) {
      content = Text("No blogs found");
    }

    return Scaffold(
      key: scaffoldKey,
      endDrawer: userAuthenticated != null ? const MyDrawer() : null,
      appBar: MyAppbar(scaffoldKey: scaffoldKey),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                if (isDesktop) ...<Widget>[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => AddBlogScreen.push(context),
                        icon: const Icon(Icons.add),
                        label: const Text("Add Blog"),
                      ),
                    ],
                  ),
                ],
                Expanded(child: content),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: userAuthenticated != null && !isDesktop
          ? BottomNavigation()
          : null,
    );
  }
}
