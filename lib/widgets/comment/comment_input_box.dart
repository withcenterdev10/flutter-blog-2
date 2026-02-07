import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/providers/comment_provider.dart';
import 'package:provider/provider.dart';

class CommentInput extends StatefulWidget {
  const CommentInput({super.key});

  @override
  State<CommentInput> createState() {
    return _CommentInputState();
  }
}

class _CommentInputState extends State<CommentInput> {
  final formKey = GlobalKey<FormState>();
  final commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void onSubmit(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      final authState = context.read<AuthProvider>().getState;
      final blogState = context.read<BlogProvider>().getBlogState;

      final comment = commentController.text;
      try {
        await context.read<CommentProvider>().createComment(
          parentId: blogState.id!,
          blogId: blogState.id!,
          userId: authState.user!.id,
          comment: comment,
          imageUrls: [],
        );
      } catch (error) {
        debugPrint(error.toString());
      } finally {
        formKey.currentState!.reset();
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Comment failed")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 8, vertical: 4),
      child: Form(
        key: formKey,
        child: SizedBox(
          height: 40,
          child: TextFormField(
            controller: commentController,
            decoration: InputDecoration(
              labelText: "Comment",
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.all(8.0),
              suffixIcon: IconButton(
                onPressed: () {
                  onSubmit(context);
                },
                icon: Icon(Icons.send),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Type your comment';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}
