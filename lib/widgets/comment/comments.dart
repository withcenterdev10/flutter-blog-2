import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/widgets/comment/comment.dart';
import 'package:provider/provider.dart';

class Comments extends StatefulWidget {
  const Comments({super.key});

  @override
  State<Comments> createState() {
    return _CommentsState();
  }
}

class _CommentsState extends State<Comments> {
  @override
  Widget build(BuildContext context) {
    final blogState = context.watch<BlogProvider>().getBlogState;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.message),
                const SizedBox(width: 5),
                Text("Comments"),
              ],
            ),
            const Divider(),
            if (blogState.comments != null)
              ...blogState.comments!.map((comment) {
                return Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Comment(comment: comment)],
                );
              }),
          ],
        ),
      ),
    );
  }
}
