import 'package:flutter/material.dart';
import 'package:flutter_blog_2/models/comment_model.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/comment_provider.dart';
import 'package:provider/provider.dart';

class CommentActions extends StatelessWidget {
  const CommentActions({super.key, required this.comment});

  final CommentModel comment;

  @override
  build(BuildContext context) {
    final commentState = context.watch<CommentProvider>().getState;
    final authState = context.watch<AuthProvider>().getState;

    return Row(
      children: [
        TextButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            context.read<CommentProvider>().setState(comment);
          },
          icon: Icon(Icons.reply, size: 18),
          label: Text(
            "Reply",
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        if (authState.user?.id == comment.user.id)
          IconButton(
            onPressed: () {
              context.read<CommentProvider>().setState(
                comment.copyWith(isEditting: true),
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            icon: Icon(Icons.edit, size: 14),
          ),
        const SizedBox(width: 8),
        if (authState.user?.id == comment.user.id)
          IconButton(
            onPressed: () {
              // context.read<CommentProvider>().setState(comment);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            icon: Icon(Icons.delete, size: 14),
          ),
      ],
    );
  }
}

    // Row(
    //               mainAxisAlignment: MainAxisAlignment.start,
    //               children: [
    //                 CommentActions(
    //                   onClick: () {
    //                     context.read<CommentProvider>().setState(comment);
    //                   },
    //                 ),
    //                 const 
               
    //               ],
    //             ),
