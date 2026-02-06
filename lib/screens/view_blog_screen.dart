import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/screens/blogs_screen.dart';
import 'package:flutter_blog_2/screens/edit_blog_screen.dart';
import 'package:flutter_blog_2/screens/home_screen.dart';
import 'package:flutter_blog_2/utils.dart';
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
  @override
  void dispose() {
    context.read<BlogProvider>().resetBlogState();
    super.dispose();
  }

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
        child: ListView(
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
                        toUpperCaseFirstChar(blogState.user!.displayName!),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),

            Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 6),
              child: const Divider(),
            ),
            Text(
              toUpperCaseFirstChar(blogState.title!),
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 15),
            Text(blogState.blog!),
            const SizedBox(height: 15),
            if (blogState.imageUrls != null)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: blogState.imageUrls!.length,
                  itemBuilder: (BuildContext context, int index) => Padding(
                    padding: EdgeInsetsGeometry.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      child: Image.network(
                        blogState.imageUrls![index],
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      // key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          truncateText(toUpperCaseFirstChar(blogState.title!), limit: 20),
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
        onPopInvokedWithResult: (didPop, result) => {
          if (didPop)
            {
              if (userState.user != null)
                {BlogsScreen.go(context)}
              else
                {HomeScreen.go(context)},
            },
        },
      ),
    );
  }
}
