import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ProfileImageBuilder extends StatelessWidget {
  const ProfileImageBuilder({
    super.key,
    this.selectedImage,
    this.webImage,
    this.profileImage,
    required this.displayName,
  });

  final String? profileImage;
  final File? selectedImage;
  final Uint8List? webImage;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    return switch ((selectedImage, webImage, profileImage)) {
      (File file?, _, _) => CircleAvatar(
        radius: 40,
        backgroundImage: FileImage(file),
      ),
      (_, Uint8List bytes?, _) => CircleAvatar(
        radius: 40,
        backgroundImage: MemoryImage(bytes),
      ),
      (_, _, String url?) => CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(url),
      ),
      _ => CircleAvatar(
        radius: 40,
        child: Text(displayName.substring(0, 2).toUpperCase()),
      ),
    };
  }
}
