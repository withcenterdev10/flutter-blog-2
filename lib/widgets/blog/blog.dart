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
    final deviceWidth = MediaQuery.of(context).size.width;
    const horizontalValues = 12.0;
    final imageWidth = (deviceWidth - (horizontalValues * 2)) / 2;
    return Card(
      margin: EdgeInsets.all(12),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          handleSelectBlog(context, blog.id!);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                horizontalValues,
                8,
                horizontalValues,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Avatar(
                    profileImage: blog.user?.imageUrl,
                    displayName: blog.user!.displayName!,
                  ),
                  const SizedBox(width: horizontalValues),
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
            ),

            const Divider(),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                horizontalValues,
                0,
                horizontalValues,
                8,
              ),
              child: Text(toUpperCaseFirstChar(blog.blog!)),
            ),

            if (blog.imageUrls != null)
              Wrap(
                children: [
                  for (var i = 0; i < blog.imageUrls!.length; i++)
                    Image.network(
                      blog.imageUrls![i],
                      width: imageWidth,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
