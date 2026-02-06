import 'package:flutter/material.dart';

class CommentInput extends StatefulWidget {
  const CommentInput({super.key});

  @override
  State<CommentInput> createState() {
    return _CommentInputState();
  }
}

class _CommentInputState extends State<CommentInput> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextFormField(
        controller: commentController,
        decoration: InputDecoration(
          labelText: "Comment",
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.all(8.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Type your comment';
          }

          return null;
        },
      ),
    );
  }
}
