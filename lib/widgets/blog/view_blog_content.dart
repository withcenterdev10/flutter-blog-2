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
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Avatar(
                profileImage: widget.blog.user!.imageUrl,
                displayName: widget.blog.user!.displayName!,
              ),
              const SizedBox(width: 8),
              Center(
                child: Text(
                  toUpperCaseFirstChar(widget.blog.user!.displayName!),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),

          const SizedBox(height: 6),
          const Divider(),
          const SizedBox(height: 6),
          Text(
            toUpperCaseFirstChar(widget.blog.title!),
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 15),
          Text(widget.blog.blog!),
          const SizedBox(height: 15),
          if (widget.blog.imageUrls != null)
            Column(
              spacing: 10,
              children: [
                ...widget.blog.imageUrls!.map((b) {
                  return ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    child: Image.network(
                      b,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                }),
              ],
            ),
          const SizedBox(height: 5),
          Comments(),
        ],
      ),
    );
  }
}
