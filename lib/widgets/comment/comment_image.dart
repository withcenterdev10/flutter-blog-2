import 'package:flutter/material.dart';

class CommentImage extends StatelessWidget {
  const CommentImage({super.key, required this.imageUrl});
  final String imageUrl;

  @override
  build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        child: Image.network(
          imageUrl,
          height: 150,
          width: 180,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
