import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.profileImage,
    required this.displayName,
  });

  final String? profileImage;
  final String displayName;

  @override
  build(BuildContext context) {
    if (profileImage != null) {
      return CircleAvatar(backgroundImage: NetworkImage(profileImage!));
    } else {
      return CircleAvatar(
        child: Text(displayName.substring(0, 2).toString().toUpperCase()),
      );
    }
  }
}
