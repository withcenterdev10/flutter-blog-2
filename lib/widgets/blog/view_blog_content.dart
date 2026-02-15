import 'package:flutter/material.dart';
import 'package:flutter_blog_2/models/auth_model.dart';
import 'package:flutter_blog_2/models/blog_model.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/screens/blogs_screen.dart';
import 'package:flutter_blog_2/utils.dart';
import 'package:flutter_blog_2/widgets/blog/view_blog_header.dart';
import 'package:flutter_blog_2/widgets/blog/view_blog_images.dart';
import 'package:flutter_blog_2/widgets/comment/comments.dart';
import 'package:provider/provider.dart';

class ViewBlogContent extends StatefulWidget {
  const ViewBlogContent({super.key, required this.blog});

  final BlogModel blog;

  @override
  State<ViewBlogContent> createState() {
    return _VewBlogContentState();
  }
}

class _VewBlogContentState extends State<ViewBlogContent> {
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

  Future<void> showDeleteDialog(BuildContext context) async {
    final authState = context.read<AuthProvider>().getState;
    final blogState = context.read<BlogProvider>().getBlogState;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 900;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          children: [
            ViewBlogHeader(
              showDeleteDialog: () {
                showDeleteDialog(context);
              },
            ),
            if (!isDesktop) ...<Widget>[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
            ],
            // Blog content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(toUpperCaseFirstChar(widget.blog.blog!)),
            ),
            const SizedBox(height: 16),

            // Blog images
            if (widget.blog.imageUrls != null)
              ViewBlogImages(imageUrls: widget.blog.imageUrls!),

            const SizedBox(height: 16),

            // Comments
            const Comments(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
