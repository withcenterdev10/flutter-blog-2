import 'package:flutter/material.dart';
import 'package:flutter_blog_2/models/blog_model.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
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
                  Avatar(
                    profileImage: blog.user?.imageUrl,
                    displayName: blog.user!.displayName!,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          toUpperCaseFirstChar(truncateText(blog.title!)),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          timeAgo(blog.createdAt!),
                          style: Theme.of(context).textTheme.bodySmall,
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
