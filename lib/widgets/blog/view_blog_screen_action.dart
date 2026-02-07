import 'package:flutter/material.dart';
import 'package:flutter_blog_2/models/auth_model.dart';
import 'package:flutter_blog_2/models/blog_model.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/screens/blogs_screen.dart';
import 'package:flutter_blog_2/screens/edit_blog_screen.dart';
import 'package:provider/provider.dart';

class ViewBlogScreenAction extends StatelessWidget {
  const ViewBlogScreenAction({super.key});

  void handleDelete(
    BuildContext context,
    BlogModel blogState,
    AuthModel userState,
  ) async {
    final isAuthor = userState.user?.id == blogState.user?.id;
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

  Future<void> showDeleteDialog(
    BuildContext context,
    BlogModel blogState,
    AuthModel authState,
  ) async {
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
                handleDelete(context, blogState, authState);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  build(BuildContext context) {
    final blogState = context.watch<BlogProvider>().getBlogState;
    final authState = context.watch<AuthProvider>().getState;
    final isAuthor = authState.user?.id == blogState.user?.id;

    return isAuthor
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  EditBlogScreen.push(context);
                },
                icon: const Icon(Icons.edit, size: 20),
              ),
              IconButton(
                onPressed: () {
                  showDeleteDialog(context, blogState, authState);
                },
                icon: const Icon(Icons.delete, size: 20),
              ),
            ],
          )
        : const SizedBox.shrink();
  }
}
