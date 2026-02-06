import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/screens/blogs_screen.dart';
import 'package:flutter_blog_2/screens/edit_blog_screen.dart';
import 'package:flutter_blog_2/utils.dart';
import 'package:flutter_blog_2/widgets/blog/view_blog_content.dart';
import 'package:flutter_blog_2/widgets/comment/comment.dart';
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
    final userState = context.watch<AuthProvider>().getState;

    Widget content = Center(child: CircularProgressIndicator(strokeWidth: 2));
    bool isAuthor = userState.user?.id == blogState.user?.id;

    void handleDelete() async {
      if (isAuthor) {
        String message = "";
        try {
          await context.read<BlogProvider>().deleteBlog(
            id: blogState.id,
            userId: userState.user!.id,
          );
          message = "Blog deleted";
        } catch (error) {
          message = "Delete blog failed";
          debugPrint(error.toString());
        } finally {
          if (context.mounted) {
            BlogsScreen.go(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Action not allowed")));
        }
      }
    }

    Future<void> showDeleteDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete blog'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Are you sure you want to delete this blog?'),
                  SizedBox(height: 10),
                  Text(blogState.title!),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Approve'),
                onPressed: () {
                  handleDelete();
                },
              ),
            ],
          );
        },
      );
    }

    if (blogState.blog != null) {
      content = Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ViewBlogContent(blog: blogState),
            const CommentInput(),
            const SizedBox(height: 10),
          ],
        ),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          blogState.title != null
              ? truncateText(toUpperCaseFirstChar(blogState.title!), limit: 20)
              : "",
        ),
        actions: isAuthor
            ? [
                IconButton(
                  onPressed: () {
                    EditBlogScreen.push(context);
                  },
                  icon: Icon(Icons.edit, size: 20),
                ),
                IconButton(
                  onPressed: () {
                    showDeleteDialog();
                  },
                  icon: Icon(Icons.delete, size: 20),
                ),
              ]
            : [],
      ),
      body: PopScope(
        child: content,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) {
            context.read<BlogProvider>().resetBlogState();
            return;
          }
        },
      ),
    );
  }
}
