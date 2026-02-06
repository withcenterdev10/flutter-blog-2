import 'package:flutter/material.dart';

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
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.message),
            const SizedBox(width: 5),
            Text("Comments"),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
