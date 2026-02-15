import 'package:flutter/material.dart';
import 'package:flutter_blog_2/widgets/profile/profile_image_bottom_sheet.dart';
import 'package:flutter_blog_2/widgets/profile/profile_image_builder.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({super.key, required this.displayName, this.profileImage});
  final String? profileImage;
  final String displayName;

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ProfileImageBottomSheet(
          displayName: displayName,
          profileImage: profileImage,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar = Stack(
      children: [
        ProfileImageBuilder(
          profileImage: profileImage,
          displayName: displayName,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: IconButton(
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(0, 0),
              ),
              onPressed: () {
                showBottomSheet(context);
              },
              icon: Icon(Icons.camera, size: 18),
            ),
          ),
        ),
      ],
    );

    return avatar;
  }
}
