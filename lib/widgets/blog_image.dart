import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class BlogImage extends StatefulWidget {
  BlogImage({
    super.key,
    this.mobileImage,
    this.webImage,
    required this.id,
    required this.onRemove,
  });

  File? mobileImage;
  Uint8List? webImage;
  final int id;
  final void Function(int id) onRemove;

  @override
  State<StatefulWidget> createState() {
    return _BlogImageState();
  }
}

class _BlogImageState extends State<BlogImage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            border: BoxBorder.all(width: 1),
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: (kIsWeb)
              ? Image.memory(
                  widget.webImage!,
                  height: 70,
                  width: 80,
                  fit: BoxFit.cover,
                )
              : Image.file(
                  widget.mobileImage!,
                  height: 70,
                  width: 80,
                  fit: BoxFit.cover,
                ),
        ),
        Positioned(
          top: -2,
          right: 4,
          child: Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.all(2),
              constraints: BoxConstraints(),
              iconSize: 14,
              onPressed: () {
                widget.onRemove(widget.id);
              },
              icon: Icon(
                Icons.close_sharp,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
