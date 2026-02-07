import 'dart:ui';

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

class _CommentInputState extends State<CommentInput>
    with WidgetsBindingObserver {
  final formKey = GlobalKey<FormState>();
  final commentController = TextEditingController();
  bool _keyboardVisible = false;
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    focusNode.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset =
        PlatformDispatcher.instance.views.first.viewInsets.bottom;
    final isVisible = bottomInset > 0;

    if (_keyboardVisible && !isVisible) {
      context.read<CommentProvider>().resetState();
      focusNode.unfocus();
    }

    _keyboardVisible = isVisible;
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
    final commentState = context.watch<CommentProvider>().getState;
    if (commentState.id != null) {
      focusNode.requestFocus();
    }

    return Padding(
      padding: EdgeInsetsGeometry.fromLTRB(
        8,
        4,
        8,
        4 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: formKey,
        child: SizedBox(
          height: 40,
          child: TextFormField(
            focusNode: focusNode,
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
