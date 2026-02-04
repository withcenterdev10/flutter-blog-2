import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ViewBlogScreen extends StatefulWidget {
  const ViewBlogScreen({super.key, required this.id});
  final String id;

  static const routeName = 'blogs/:id';
  static const callRouteName = "/$routeName";

  static Function(BuildContext context, String id) go = (context, id) =>
      context.go(callRouteName.replaceFirst(":id", id));

  static Function(BuildContext context) push = (context) =>
      context.push(routeName);

  @override
  State<ViewBlogScreen> createState() {
    return _ViewBlogScreenState();
  }
}

class _ViewBlogScreenState extends State<ViewBlogScreen> {
  @override
  Widget build(BuildContext context) {
    return Text("data");
  }
}
