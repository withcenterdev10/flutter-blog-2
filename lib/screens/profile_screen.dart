import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/widgets/layout/appbar.dart';
import 'package:flutter_blog_2/widgets/my_drawer.dart';
import 'package:flutter_blog_2/widgets/profile/profile_image.dart';
import 'package:flutter_blog_2/widgets/submit_button.dart';
import 'package:flutter_blog_2/widgets/unfocus_close_keyboard.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class Profile extends StatefulWidget {
  const Profile({super.key});

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

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    final authState = context.watch<AuthProvider>().getState;

    void onSubmit() async {
      if (formKey.currentState!.validate()) {
        final name = nameController.text;
        String message = "";
        try {
          await context.read<AuthProvider>().updateUser(name: name);

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
        }
      }
    }

    final userId = context.select<AuthProvider, String?>(
      (provider) => provider.getState.user?.id,
    );

    return UnfocusCloseKeyboard(
      child: Scaffold(
        key: scaffoldKey,
        appBar: MyAppbar(scaffoldKey: scaffoldKey),
        endDrawer: userId != null ? MyDrawer() : null,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  Center(child: ProfileImage()),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

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
                          child: SubmitButton(
                            onSubmit: onSubmit,
                            loading: authState.loading,
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
      ),
    );
  }
}
