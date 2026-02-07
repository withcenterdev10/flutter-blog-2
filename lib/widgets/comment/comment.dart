import 'package:flutter/material.dart';
import 'package:flutter_blog_2/models/comment_model.dart';
import 'package:flutter_blog_2/utils.dart';
import 'package:flutter_blog_2/widgets/avatar.dart';
import 'package:flutter_blog_2/widgets/comment/comment_image.dart';

class Comment extends StatelessWidget {
  const Comment({super.key, required this.comment});

  final CommentModel comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Avatar(
            profileImage: comment.user!.imageUrl,
            displayName: comment.user!.displayName!,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                toUpperCaseFirstChar(comment.user!.displayName!),
              ),
              Text(timeAgo(comment.createdAt!)),
              const SizedBox(height: 6),
              Text(toUpperCaseFirstChar(comment.comment!)),
              const SizedBox(height: 6),
              if (comment.imageUrls != null && comment.imageUrls!.isNotEmpty)
                CommentImage(imageUrl: comment.imageUrls![0]),
            ],
          ),
        ],
      ),
    );
  }
}
