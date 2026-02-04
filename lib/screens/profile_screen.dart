import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class Profile extends StatefulWidget {
  const Profile({super.key});

  // static const routeName = '/profile/:id';

  // static Function(BuildContext context, String id) go = (context, id) =>
  //     context.go(routeName.replaceFirst(':id', id));

  static const routeName = 'profile';
  static const callRouteName = '/$routeName';

  static Function(BuildContext context) go = (context) =>
      context.go(callRouteName);

  static Function(BuildContext context) push = (context) =>
      context.push(routeName);

  @override
  State<Profile> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<Profile> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  File? selectedImage;
  String? selectedImagePath;
  Uint8List? webImage;

  @override
  void initState() {
    final authState = context.read<Auth>().getState;
    nameController = TextEditingController(
      text: authState.user?.userMetadata?['display_name'],
    );
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void openImagePicker() async {
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    // mobile
    if (!kIsWeb) {
      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
          selectedImagePath = image.path;
        });
      }
    } else {
      // web
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          webImage = f;
        });
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
    final authState = context.watch<Auth>().getState;
    final profileImage = authState.user?.userMetadata?['image_url'];
    final displayName = authState.user?.userMetadata?['display_name'];

    void onSubmit() async {
      if (formKey.currentState!.validate()) {
        final name = nameController.text;
        String message = "";
        try {
          await context.read<Auth>().updateUser(
            name: name,
            image: selectedImage,
          );

          message = "User updated successfully";
        } catch (error) {
          message = "User update failed";
          debugPrint(error.toString());
        } finally {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }

          removeSelectedImage();
        }
      }
    }

    Widget avatar = Stack(
      children: [
        CircleAvatar(
          radius: 40,
          child: Text(displayName.substring(0, 2).toString().toUpperCase()),
        ),
        Positioned(
          bottom: -4,
          right: -4,
          child: IconButton(
            onPressed: openImagePicker,
            icon: Icon(Icons.camera),
          ),
        ),
      ],
    );

    if (profileImage != null) {
      avatar = Stack(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(profileImage!),
          ),
          Positioned(
            bottom: -4,
            right: -4,
            child: IconButton(
              onPressed: openImagePicker,
              icon: Icon(Icons.camera),
            ),
          ),
        ],
      );
    }

    if (selectedImage != null || webImage != null) {
      avatar = Stack(
        children: [
          CircleAvatar(
            radius: 40,
            child: ClipOval(
              child: (kIsWeb)
                  ? Image.memory(webImage!, fit: BoxFit.cover)
                  : Image.file(selectedImage!, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
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
                onPressed: removeSelectedImage,
                icon: Icon(Icons.close_sharp, color: Colors.red),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            children: [
              avatar,
              const SizedBox(height: 15),
              const Divider(),
              const SizedBox(height: 15),
              Form(
                key: formKey,
                child: TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSubmit,
                  child: authState.loading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text("Submitting..."),
                          ],
                        )
                      : Text(
                          "Submit",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
