import 'package:flutter/material.dart';
import 'package:flutter_blog_2/screens/add_blog_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_blog_2/screens/home_screen.dart';
import 'package:flutter_blog_2/screens/profile_screen.dart';
import 'package:flutter_blog_2/screens/blogs_screen.dart';

/// The route configuration.
final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext contehomext, GoRouterState state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: Profile.routeName,
          builder: (BuildContext context, GoRouterState state) {
            return const Profile();
          },
        ),
        GoRoute(
          path: Blogs.routeName,
          builder: (BuildContext context, GoRouterState state) {
            return const Blogs();
          },
          routes: <RouteBase>[
            GoRoute(
              path: AddBlogScreen.routeName,
              builder: (BuildContext context, GoRouterState state) {
                return const AddBlogScreen();
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
