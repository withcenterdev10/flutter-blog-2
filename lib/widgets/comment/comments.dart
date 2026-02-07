import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/utils.dart';
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

    return Column(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(2),
                  child: Row(
                    spacing: 6,
                    children: [
                      CircleAvatar(
                        // change this la
                        backgroundImage: NetworkImage(
                          "https://placehold.co/600x400",
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            toUpperCaseFirstChar(comment.user!.displayName!),
                          ),
                          //  Text(comment.created_at),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(comment.comment!),
              ],
            );
          }),
      ],
    );
  }
}
