import 'package:flutter/material.dart';
import 'package:flutter_blog_2/models/blog_model.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/screens/view_blog_screen.dart';
import 'package:flutter_blog_2/utils.dart';
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

  @override
  Widget build(BuildContext context) {
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
                  blog.user?.imageUrl != null
                      ? CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(blog.user!.imageUrl!),
                        )
                      : CircleAvatar(
                          radius: 25,
                          child: Text(
                            blog.user!.displayName!
                                .substring(0, 2)
                                .toUpperCase(),
                          ),
                        ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          truncateText(blog.title!),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
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
            ],
          ),
        ),
      ),
    );
  }
}
