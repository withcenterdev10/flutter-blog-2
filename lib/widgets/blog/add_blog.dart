import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/screens/view_blog_screen.dart';
import 'package:flutter_blog_2/widgets/blog_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

int imageLimit = 3;

class AddBlog extends StatefulWidget {
  const AddBlog({super.key});

  @override
  State<AddBlog> createState() {
    return _AddBlogState();
  }
}

class _AddBlogState extends State<AddBlog> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final blogController = TextEditingController();
  List<BlogImage> selectedBlogImages = [];
  List<File>? selectedImages = [];

  void removeImage(int imageId) {
    setState(() {
      selectedBlogImages = selectedBlogImages
          .where((img) => img.id != imageId)
          .toList();
    });
  }

  Future<({File? mobileImage, Uint8List? webImage})> openImagePicker() async {
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    File? mobileImage;
    Uint8List? webImage;

    // mobile
    if (!kIsWeb) {
      if (image != null) {
        mobileImage = File(image.path);
      }
    } else {
      // web
      if (image != null) {
        webImage = await image.readAsBytes();
      }
    }

    return (mobileImage: mobileImage, webImage: webImage);
  }

  void handleAddImage() async {
    var (:mobileImage, :webImage) = await openImagePicker();
    List<BlogImage> updatedImages = [
      ...selectedBlogImages,
      BlogImage(
        mobileImage: mobileImage,
        webImage: webImage,
        id: selectedBlogImages.length + 1,
        onRemove: removeImage,
      ),
    ];

    var updatedSelectedImages = selectedImages;

    if (mobileImage != null) {
      updatedSelectedImages?.add(mobileImage);
    }

    setState(() {
      selectedBlogImages = updatedImages;
      selectedImages = updatedSelectedImages;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AuthProvider>().getState;
    final blogState = context.watch<BlogProvider>().getBlogState;

    void onSubmit() async {
      if (formKey.currentState!.validate()) {
        final title = titleController.text;
        final blog = titleController.text;
        final userId = userState.user!.id;
        String message = "";
        try {
          final blogId = await context.read<BlogProvider>().createBlog(
            blog: blog,
            userId: userId,
            title: title,
            images: selectedImages,
          );
          message = "Create blog success";
          if (context.mounted) {
            ViewBlogScreen.push(context, blogId as String);
          }
        } catch (error) {
          message = "Create blog failed";
          debugPrint(error.toString());
        } finally {
          formKey.currentState!.reset();
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            TextFormField(
              autofocus: true,
              maxLength: 50,
              controller: titleController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter title of your blog';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),

            TextFormField(
              maxLines: 8,
              controller: blogController,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter title of your blog';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            Text("${selectedBlogImages.length} / $imageLimit"),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 10),
              child: Row(
                children: [
                  ...selectedBlogImages,
                  if (selectedBlogImages.length < imageLimit)
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).highlightColor,
                        border: BoxBorder.all(width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      child: IconButton(
                        onPressed: handleAddImage,
                        icon: Icon(Icons.add),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubmit,
                child: blogState.loading
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
    );
  }
}
