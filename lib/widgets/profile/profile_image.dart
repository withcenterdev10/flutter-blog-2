import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/widgets/profile/profile_image_bottom_sheet.dart';
import 'package:flutter_blog_2/widgets/profile/profile_image_builder.dart';
import 'package:provider/provider.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({super.key});

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ProfileImageBottomSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final (:profileImage, :displayName) = context
        .select<AuthProvider, ({String? profileImage, String displayName})>((
          provider,
        ) {
          final user = provider.getState.user;
          return (
            profileImage: user?.userMetadata?['image_url'],
            displayName: user?.userMetadata?['display_name'],
          );
        });

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
