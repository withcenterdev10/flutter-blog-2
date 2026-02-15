import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter_blog_2/screens/view_image_screen.dart';

class ViewBlogImages extends StatelessWidget {
  const ViewBlogImages({super.key, required this.imageUrls});
  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: imageUrls.map((url) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ViewImageScreen(imageUrl: url)),
            );
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 425, maxHeight: 325),
            child: Image.network(
              url,
              width: double.infinity,
              height: 325,
              fit: BoxFit.cover,
            ),
          ),
        );
        ;
      }).toList(),
    );
  }
}
