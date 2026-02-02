import 'package:flutter/material.dart';
import 'package:flutter_blog_2/screens/add_blog.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_blog_2/screens/home_screen.dart';
import 'package:flutter_blog_2/screens/profile.dart';
import 'package:flutter_blog_2/screens/blogs.dart';

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
              path: AddBlog.routeName,
              builder: (BuildContext context, GoRouterState state) {
                return const AddBlog();
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
