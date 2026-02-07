import 'package:flutter/material.dart';

class Avatar extends StatefulWidget {
  const Avatar({
    super.key,
    required this.profileImage,
    required this.displayName,
  });

  final String? profileImage;
  final String displayName;

  @override
  State<StatefulWidget> createState() {
    return _AvatarState();
  }
}

class _AvatarState extends State<Avatar> {
  @override
  build(BuildContext context) {
    if (widget.profileImage != null) {
      return CircleAvatar(backgroundImage: NetworkImage(widget.profileImage!));
    } else {
      return CircleAvatar(
        child: Text(
          widget.displayName.substring(0, 2).toString().toUpperCase(),
        ),
      );
    }
  }
}
