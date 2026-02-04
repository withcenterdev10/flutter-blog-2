import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/screens/edit_blog_screen.dart';
import 'package:flutter_blog_2/utils.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ViewBlogScreen extends StatefulWidget {
  const ViewBlogScreen({super.key, required this.id});
  final String id;

  static const routeName = 'blogs/:id';
  static const callRouteName = "/$routeName";

  static Function(BuildContext context, String id) go = (context, id) =>
      context.go(callRouteName.replaceFirst(":id", id));

  static Function(BuildContext context, String id) push = (context, id) =>
      context.push(callRouteName.replaceFirst(":id", id));

  @override
  State<ViewBlogScreen> createState() {
    return _ViewBlogScreenState();
  }
}

class _ViewBlogScreenState extends State<ViewBlogScreen> {
  @override
  Widget build(BuildContext context) {
    final blogState = context.watch<BlogProvider>().getBlogState;
    final userState = context.watch<AuthProvider>().getState;

    Widget content = Center(child: CircularProgressIndicator(strokeWidth: 2));
    bool isAuthor = userState.user?.id == blogState.user?.id;

    if (blogState.blog != null) {
      content = ListView(
        padding: EdgeInsets.all(12),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    blogState.user?.imageUrl != null
                        ? CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                              blogState.user!.imageUrl!,
                            ),
                          )
                        : CircleAvatar(
                            radius: 25,
                            child: Text(
                              blogState.user!.displayName!
                                  .substring(0, 2)
                                  .toUpperCase(),
                            ),
                          ),
                    const SizedBox(width: 8),
                    Text(
                      toUpperCaseFirstChar(blogState.title!),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              isAuthor
                  ? IconButton(
                      onPressed: () {
                        EditBlogScreen.push(context);
                      },
                      icon: Icon(Icons.edit, size: 20),
                    )
                  : const SizedBox.shrink(),
              isAuthor
                  ? IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.delete, size: 20),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 6),
            child: const Divider(),
          ),
          Text(
            toUpperCaseFirstChar(blogState.title!),
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 15),
          Text(blogState.blog!),
        ],
      );
    }
    return Scaffold(
      // key: scaffoldKey,
      appBar: AppBar(title: const Text('View Blog')),
      body: content,
    );
  }
}
