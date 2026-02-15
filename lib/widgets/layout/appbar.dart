import 'package:flutter/material.dart';
import 'package:flutter_blog_2/models/auth_model.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/providers/screen_provider.dart';
import 'package:flutter_blog_2/screens/blogs_screen.dart';
import 'package:flutter_blog_2/screens/home_screen.dart';
import 'package:flutter_blog_2/widgets/home_avatar.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppbar({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    final userAuthenticated = context.select<AuthProvider, User?>(
      (p) => p.getState.user,
    );

    bool isDesktop = MediaQuery.of(context).size.width >= 900;

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

    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      actions: [const SizedBox()],
      title: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Row(
            children: [
              GestureDetector(
                child: isDesktop
                    ? Text("Home")
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text("Home"),
                      ),
                onTap: () {
                  handleNavigationClick(context, 0);
                },
              ),
              const Spacer(),

              if (isDesktop && userAuthenticated != null)
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
    );
  }
}
