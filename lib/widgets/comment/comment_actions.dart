import 'package:flutter/material.dart';
import 'package:flutter_blog_2/models/auth_model.dart';
import 'package:flutter_blog_2/models/comment_model.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/providers/comment_provider.dart';
import 'package:provider/provider.dart';

class CommentActions extends StatelessWidget {
  const CommentActions({super.key, required this.comment, required this.depth});

  final int depth;

  final CommentModel comment;
  void handleDelete(
    BuildContext context,
    CommentModel commentState,
    AuthModel authState,
  ) async {
    if (context.mounted) {
      if (commentState.comments != null && commentState.comments!.isNotEmpty) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Cannot delete comment having nested comment"),
          ),
        );
        return;
      }
    }

    final isAuthor = authState.user?.id == commentState.user.id;
    if (isAuthor) {
      String message = "";
      try {
        final deletedComment = await context
            .read<CommentProvider>()
            .deleteComment(
              commentId: commentState.id!,
              userId: authState.user!.id,
            );
        message = "Comment deleted";
        if (context.mounted) {
          context.read<BlogProvider>().deleteComment(deletedComment);
        }
      } catch (error) {
        message = "Delete Comment failed";
        debugPrint(error.toString());
      } finally {
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Action not allowed")));
    }
  }

  Future<void> showDeleteDialog(
    BuildContext context,
    CommentModel commentState,
    AuthModel authState,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete comment'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this comment?'),
                SizedBox(height: 10),
                Text(comment.comment),
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
                handleDelete(context, commentState, authState);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  build(BuildContext context) {
    final authState = context.watch<AuthProvider>().getState;

    return Row(
      children: [
        if (authState.user != null)
          TextButton.icon(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              if (depth == 3) {
                context.read<CommentProvider>().setState(
                  comment.copyWith(isToDeep: true),
                );
              } else {
                context.read<CommentProvider>().setState(
                  comment.copyWith(isEditting: false, isDeleting: false),
                );
              }
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
                comment.copyWith(isEditting: true, isDeleting: false),
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
              context.read<CommentProvider>().setState(
                comment.copyWith(isDeleting: true, isEditting: false),
              );
              showDeleteDialog(context, comment, authState);
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
