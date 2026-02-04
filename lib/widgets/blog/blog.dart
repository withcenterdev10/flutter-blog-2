import 'package:flutter/material.dart';
import 'package:flutter_blog_2/models/blog_model.dart';
import 'package:flutter_blog_2/utils.dart';

class Blog extends StatelessWidget {
  const Blog({super.key, required this.blog});

  final BlogModel blog;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                        blog.user!.displayName!.substring(0, 2).toUpperCase(),
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
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Text(blog.blog!),
          ),
        ],
      ),
    );
  }
}
