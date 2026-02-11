import 'package:flutter/material.dart';
import 'package:flutter_blog_2/models/auth_model.dart';
import 'package:flutter_blog_2/models/blog_model.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/screens/blogs_screen.dart';
import 'package:flutter_blog_2/screens/edit_blog_screen.dart';
import 'package:flutter_blog_2/screens/view_blog_screen.dart';
import 'package:flutter_blog_2/utils.dart';
import 'package:flutter_blog_2/widgets/avatar.dart';
import 'package:provider/provider.dart';

class Blog extends StatelessWidget {
  const Blog({super.key, required this.blog});

  final BlogModel blog;

  void handleSelectBlog(BuildContext context, String id) async {
    try {
      ViewBlogScreen.push(context, blog.id!);
      await context.read<BlogProvider>().getBlog(id);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

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
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 900;
    final blogState = context.watch<BlogProvider>().getBlogState;
    final authState = context.watch<AuthProvider>().getState;
    final isAuthor = authState.user?.id == blog.user?.id;

    return Card(
      margin: EdgeInsets.all(12),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          handleSelectBlog(context, blog.id!);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Avatar(
                    profileImage: blog.user?.imageUrl,
                    displayName: blog.user!.displayName!,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          truncateText(blog.title!),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isDesktop && isAuthor) ...<Widget>[
                          const Spacer(),
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
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: EdgeInsetsGeometry.symmetric(vertical: 4),
                child: const Divider(),
              ),
              Text(blog.blog!),

              if (blog.imageUrls != null)
                Wrap(
                  children: [
                    for (var i = 0; i < blog.imageUrls!.length; i++)
                      Padding(
                        padding: EdgeInsetsGeometry.all(4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          child: Image.network(
                            blog.imageUrls![i],
                            width: 140,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
