import 'package:flutter/material.dart';
import 'package:flutter_blog_2/models/comment_model.dart';
import 'package:flutter_blog_2/providers/comment_provider.dart';
import 'package:flutter_blog_2/utils.dart';
import 'package:flutter_blog_2/widgets/avatar.dart';
import 'package:flutter_blog_2/widgets/comment/comment_image.dart';
import 'package:flutter_blog_2/widgets/comment/comment_actions.dart';
import 'package:provider/provider.dart';

class Comment extends StatelessWidget {
  const Comment({super.key, required this.comment, this.depth = 1});
  final CommentModel comment;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final commentState = context.watch<CommentProvider>().getState;
    bool isSelectedComment = commentState.id == comment.id;

    return Container(
      color: isSelectedComment
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.10)
          : null,
      padding: EdgeInsets.all(2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Avatar(
            profileImage: comment.user.imageUrl,
            displayName: comment.user.displayName!,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                  toUpperCaseFirstChar(comment.user.displayName!),
                ),
                Text(timeAgo(comment.createdAt!)),
                const SizedBox(height: 6),
                Text(toUpperCaseFirstChar(comment.comment)),
                const SizedBox(height: 6),
                if (comment.imageUrls != null && comment.imageUrls!.isNotEmpty)
                  ...comment.imageUrls!.map((img) {
                    return CommentImage(imageUrl: img);
                  }),

                const SizedBox(height: 6),
                CommentActions(comment: comment, depth: depth),
                const SizedBox(height: 6),
                if (comment.comments != null && comment.comments!.isNotEmpty)
                  ...comment.comments!.map(
                    (c) => Comment(comment: c, depth: depth + 1),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
