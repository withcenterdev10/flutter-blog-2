import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/widgets/submit_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_2/widgets/profile/profile_image_builder.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';

class ProfileImageBottomSheet extends StatefulWidget {
  const ProfileImageBottomSheet({
    super.key,
    this.profileImage,
    this.selectedImage,
    this.webImage,
    required this.displayName,
  });

  final String? profileImage;
  final Uint8List? webImage;
  final File? selectedImage;
  final String displayName;
  @override
  State<ProfileImageBottomSheet> createState() =>
      _ProfileImageBottomSheetState();
}

class _ProfileImageBottomSheetState extends State<ProfileImageBottomSheet> {
  File? selectedImage;
  String? selectedImagePath;
  Uint8List? webImage;

  Future<bool> openImagePicker() async {
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return false;

    // mobile
    if (!kIsWeb) {
      setState(() {
        selectedImage = File(image.path);
        selectedImagePath = image.path;
      });
    } else {
      // web
      var f = await image.readAsBytes();
      setState(() {
        webImage = f;
      });
    }

    return true;
  }

  void onSubmit(BuildContext context) async {
    String message = "";
    try {
      await context.read<AuthProvider>().updateUser(
        image: selectedImage,
        webImage: webImage,
      );

      message = "User updated successfully";
    } catch (error) {
      message = "User update failed";
      debugPrint(error.toString());
    } finally {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  void removeSelectedImage() {
    setState(() {
      selectedImage = null;
      selectedImagePath = null;
      webImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthProvider>().getState;
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            padding: EdgeInsets.only(top: 42),
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.close),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Stack(
                  children: [
                    ProfileImageBuilder(
                      profileImage: widget.profileImage,
                      selectedImage: selectedImage,
                      webImage: webImage,
                      displayName: widget.displayName,
                    ),
                    if (selectedImage != null || webImage != null)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(100),
                            ),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.all(2),
                            constraints: BoxConstraints(),
                            iconSize: 14,
                            onPressed: () {
                              removeSelectedImage();
                            },
                            icon: Icon(Icons.close_sharp, color: Colors.red),
                          ),
                        ),
                      ),
                  ],
                ),

                if ((selectedImage == null && webImage == null)) ...<Widget>[
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await openImagePicker();
                      },
                      label: Text("Upload from devices"),
                      icon: Icon(Icons.upload),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      label: Text("Take a picture"),
                      icon: Icon(Icons.camera),
                    ),
                  ),
                ],

                if ((selectedImage != null || webImage != null))
                  SubmitButton(
                    loading: authState.loading,
                    onSubmit: () {
                      onSubmit(context);
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
