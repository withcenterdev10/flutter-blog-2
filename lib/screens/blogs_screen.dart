import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/screens/add_blog_screen.dart';
import 'package:flutter_blog_2/widgets/blog/blog_content.dart';
import 'package:flutter_blog_2/widgets/bottom_navigation.dart';
import 'package:flutter_blog_2/widgets/layout/appbar.dart';
import 'package:flutter_blog_2/widgets/my_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final userAuthenticated = context.select<AuthProvider, User?>(
      (p) => p.getState.user,
    );
    bool isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      key: scaffoldKey,
      endDrawer: userAuthenticated != null ? const MyDrawer() : null,
      appBar: MyAppbar(scaffoldKey: scaffoldKey),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
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
                Expanded(child: BlogContent()),
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
