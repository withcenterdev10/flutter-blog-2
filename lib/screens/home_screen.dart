import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/providers/screen_provider.dart';
import 'package:flutter_blog_2/screens/blogs_screen.dart';
import 'package:flutter_blog_2/widgets/blog/blog_content.dart';
import 'package:flutter_blog_2/widgets/bottom_navigation.dart';
import 'package:flutter_blog_2/widgets/layout/appbar.dart';
import 'package:flutter_blog_2/widgets/my_drawer.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthProvider>().getState;
      context.read<BlogProvider>().getBlogs(authState.user?.id);
    });
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();

  void handleNavigationClick(BuildContext context, int screenIndex) {
    context.read<ScreenProvider>().setScreen(screenIndex);
    if (screenIndex == 1) {
      BlogsScreen.go(context);
    }
    if (screenIndex == 0) {
      HomeScreen.go(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 900;
    final userAuthenticated = context.select<AuthProvider, User?>(
      (p) => p.getState.user,
    );

    return Scaffold(
      key: scaffoldKey,
      appBar: MyAppbar(scaffoldKey: scaffoldKey),
      endDrawer: userAuthenticated != null ? const MyDrawer() : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: BlogContent(),
          ),
        ),
      ),
      bottomNavigationBar: userAuthenticated != null && !isDesktop
          ? BottomNavigation()
          : null,
    );
  }
}
