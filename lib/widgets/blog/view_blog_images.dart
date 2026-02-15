import 'package:flutter/material.dart';

class ViewBlogImages extends StatelessWidget {
  const ViewBlogImages({super.key, required this.imageUrls});
  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: imageUrls.map((url) {
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 425, maxHeight: 325),
          child: Image.network(
            url,
            width: double.infinity,
            height: 325,
            fit: BoxFit.cover,
          ),
        );
      }).toList(),
    );
  }
}
