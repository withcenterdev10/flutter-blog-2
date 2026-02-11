import 'package:flutter/material.dart';
import 'package:flutter_blog_2/models/blog_model.dart';
import 'package:flutter_blog_2/utils.dart';
import 'package:flutter_blog_2/widgets/avatar.dart';
import 'package:flutter_blog_2/widgets/comment/comments.dart';

class ViewBlogContent extends StatefulWidget {
  const ViewBlogContent({super.key, required this.blog});

  final BlogModel blog;

  @override
  State<ViewBlogContent> createState() {
    return _VewBlogContentState();
  }
}

class _VewBlogContentState extends State<ViewBlogContent> {
  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 900;

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
            Text(
              toUpperCaseFirstChar(widget.blog.title!),
              style: Theme.of(context).textTheme.headlineLarge,
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
