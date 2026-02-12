import 'package:flutter/material.dart';
import 'package:flutter_blog_2/models/auth_model.dart';
import 'package:flutter_blog_2/models/blog_model.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/screens/blogs_screen.dart';
import 'package:flutter_blog_2/screens/edit_blog_screen.dart';
import 'package:flutter_blog_2/utils.dart';
import 'package:flutter_blog_2/widgets/avatar.dart';
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

  Future<void> showDeleteDialog(
    BuildContext context,
    BlogModel blogState,
    AuthModel authState,
  ) async {
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
    final authState = context.watch<AuthProvider>().getState;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Avatar(
                    profileImage: widget.blog.user!.imageUrl,
                    displayName: widget.blog.user!.displayName!,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      toUpperCaseFirstChar(widget.blog.user!.displayName!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),

            if (!isDesktop) ...<Widget>[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
            ],

            // Blog title
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      softWrap: true,
                      toUpperCaseFirstChar(widget.blog.title!),
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),

                  if (isDesktop) ...<Widget>[
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        EditBlogScreen.push(context);
                      },
                      icon: const Icon(Icons.edit, size: 20),
                    ),
                    IconButton(
                      onPressed: () {
                        showDeleteDialog(context, widget.blog, authState);
                      },
                      icon: const Icon(Icons.delete, size: 20),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),
            Text(
              "Author: ${toUpperCaseFirstChar(widget.blog.user!.displayName!)}",
            ),
            const SizedBox(height: 16),
            // Blog content
            Text(widget.blog.blog!),
            const SizedBox(height: 16),

            // Blog images
            if (widget.blog.imageUrls != null)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: widget.blog.imageUrls!.map((url) {
                  return ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 200,
                      maxHeight: 200,
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      child: Image.network(
                        url,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),

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
