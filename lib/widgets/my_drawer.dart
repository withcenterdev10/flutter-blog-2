import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/screens/blogs.dart';
import 'package:flutter_blog_2/utils.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blog_2/screens/profile.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() {
    return _MyDrawerState();
  }
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    void handleLogout() async {
      String? message;
      try {
        await context.read<Auth>().logout();
      } catch (error) {
        debugPrint(error.toString());
        message = "Something went wrong";
      } finally {
        if (context.mounted) {
          Navigator.of(context).pop();
          if (message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        }
      }
    }

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              children: [
                Icon(
                  Icons.book,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 18),
                Text(
                  'Blogs',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings, size: 26),
            title: Text('Profile'),
            onTap: () {
              Navigator.of(context).pop();
              Profile.go(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.book, size: 26),
            title: Text('My blogs'),
            onTap: () {
              Navigator.of(context).pop();
              Blogs.go(context);
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, size: 26),
            title: Text('Logout'),
            onTap: handleLogout,
          ),
        ],
      ),
    );
  }
}
