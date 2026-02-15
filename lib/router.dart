import 'package:flutter/material.dart';
import 'package:flutter_blog_2/screens/add_blog_screen.dart';
import 'package:flutter_blog_2/screens/auth/sign_in.dart';
import 'package:flutter_blog_2/screens/auth/sign_up.dart';
import 'package:flutter_blog_2/screens/edit_blog_screen.dart';
import 'package:flutter_blog_2/screens/view_blog_screen.dart';
import 'package:flutter_blog_2/screens/view_image_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_blog_2/screens/home_screen.dart';
import 'package:flutter_blog_2/screens/profile_screen.dart';
import 'package:flutter_blog_2/screens/blogs_screen.dart';

/// The route configuration.
final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext contehomext, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: SignUpScreen.routeName,
      builder: (BuildContext contehomext, GoRouterState state) {
        return const SignUpScreen();
      },
    ),
    GoRoute(
      path: SignInScreen.routeName,
      builder: (BuildContext contehomext, GoRouterState state) {
        return const SignInScreen();
      },
    ),
    GoRoute(
      path: Profile.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const Profile();
      },
    ),
    GoRoute(
      path: BlogsScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const BlogsScreen();
      },
    ),
    GoRoute(
      path: AddBlogScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const AddBlogScreen();
      },
    ),
    GoRoute(
      path: EditBlogScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const EditBlogScreen();
      },
    ),
    GoRoute(
      path: ViewBlogScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return ViewBlogScreen(id: state.pathParameters['id']!);
      },
    ),
    GoRoute(
      path: ViewImageScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return ViewImageScreen(imageUrl: state.pathParameters['imageUrl']!);
      },
    ),
  ],
);
