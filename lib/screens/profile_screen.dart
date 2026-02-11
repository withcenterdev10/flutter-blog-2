import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/utils.dart';
import 'package:flutter_blog_2/widgets/layout/appbar.dart';
import 'package:flutter_blog_2/widgets/my_drawer.dart';
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

  static const routeName = '/profile';

  static Function(BuildContext context) go = (context) => context.go(routeName);

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
    final authState = context.read<AuthProvider>().getState;
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
    final scaffoldKey = GlobalKey<ScaffoldState>();

    final authState = context.watch<AuthProvider>().getState;
    final profileImage = authState.user?.userMetadata?['image_url'];
    final displayName = authState.user?.userMetadata?['display_name'];

    void onSubmit() async {
      if (formKey.currentState!.validate()) {
        final name = nameController.text;
        String message = "";
        try {
          await context.read<AuthProvider>().updateUser(
            name: name,
            image: selectedImage,
            webImage: webImage,
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
            backgroundImage: kIsWeb
                ? MemoryImage(webImage!)
                : FileImage(selectedImage!),
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
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withAlpha(100),
                ),
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
      key: scaffoldKey,
      appBar: MyAppbar(scaffoldKey: scaffoldKey),
      endDrawer: authState.user != null ? const MyDrawer() : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Avatar at the top
                Center(child: avatar),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),

                // Form section
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Name",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
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
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text("Submitting..."),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
