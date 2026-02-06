import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/providers/screen_provider.dart';
import 'package:flutter_blog_2/screens/blogs_screen.dart';
import 'package:flutter_blog_2/screens/home_screen.dart';
import 'package:provider/provider.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<StatefulWidget> createState() {
    return _BottomNavigationState();
  }
}

class _BottomNavigationState extends State<BottomNavigation> {
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
    final screenState = context.watch<ScreenProvider>().getState;
    return BottomNavigationBar(
      onTap: (value) {
        handleNavigationClick(context, value);
      },
      currentIndex: screenState,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'All'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'My Blogs'),
      ],
    );
  }
}
