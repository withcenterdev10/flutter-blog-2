import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/screens/blogs_screen.dart';
import 'package:flutter_blog_2/screens/edit_blog_screen.dart';
import 'package:flutter_blog_2/utils.dart';
import 'package:flutter_blog_2/widgets/blog/view_blog_content.dart';
import 'package:flutter_blog_2/widgets/blog/view_blog_screen_action.dart';
import 'package:flutter_blog_2/widgets/comment/comment_input_box.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ViewBlogScreen extends StatefulWidget {
  const ViewBlogScreen({super.key, required this.id});
  final String id;

  static const routeName = '/blogs/:id';
  static const callRouteName = "/$routeName";

  static Function(BuildContext context, String id) go = (context, id) =>
      context.go(routeName.replaceFirst(":id", id));

  static Function(BuildContext context, String id) push = (context, id) =>
      context.push(routeName.replaceFirst(":id", id));

  @override
  State<ViewBlogScreen> createState() {
    return _ViewBlogScreenState();
  }
}

class _ViewBlogScreenState extends State<ViewBlogScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final blogState = context.watch<BlogProvider>().getBlogState;
    final blogTitle = blogState.title != null
        ? truncateText(toUpperCaseFirstChar(blogState.title!), limit: 20)
        : "";

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: Text(blogTitle), actions: [ViewBlogScreenAction()]),
      body: PopScope(
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) {
            context.read<BlogProvider>().resetBlogState();
            return;
          }
        },

        child: blogState.blog != null
            ? ViewBlogContent(blog: blogState)
            : Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      bottomNavigationBar: SafeArea(child: const CommentInput()),
    );
  }
}
