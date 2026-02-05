import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/widgets/blog_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blog_2/utils.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EditBlog extends StatefulWidget {
  const EditBlog({super.key});

  @override
  State<EditBlog> createState() {
    return _EditBlogState();
  }
}

class _EditBlogState extends State<EditBlog> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController blogController;
  List<BlogImage> selectedBlogImages = [];
  List<File> selectedImages = [];

  void removeImage(String imageId) {
    setState(() {
      selectedBlogImages = selectedBlogImages
          .where((img) => img.id != imageId)
          .toList();
    });
  }

  @override
  void initState() {
    final blogState = context.read<BlogProvider>().getBlogState;
    titleController = TextEditingController(text: blogState.title);
    blogController = TextEditingController(text: blogState.blog);

    if (blogState.imageUrls != null) {
      blogState.imageUrls!.forEach((b) {
        selectedBlogImages.add(
          BlogImage(id: b, networImage: b, onRemove: removeImage),
        );
      });
    }

    super.initState();
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
        id: '${selectedBlogImages.length + 1}',
        onRemove: removeImage,
      ),
    ];

    var updatedSelectedImages = selectedImages;

    if (mobileImage != null) {
      updatedSelectedImages.add(mobileImage);
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
        final blog = blogController.text;
        final userId = userState.user!.id;

        List<String> remainingPreviousImgUrls = [];

        if (selectedBlogImages.isNotEmpty) {
          for (var i = 0; i < selectedBlogImages.length; i++) {
            if (selectedBlogImages[i].networImage != null) {
              remainingPreviousImgUrls.add(
                selectedBlogImages[i].networImage as String,
              );
            }
          }
        }

        String message = "";
        try {
          await context.read<BlogProvider>().updateBlog(
            id: blogState.id!,
            blogContent: blog,
            userId: userId,
            title: title,
            newImages: selectedImages,
            networkImages: remainingPreviousImgUrls,
          );
          message = "Update blog success";
        } catch (error) {
          message = "Update blog failed";
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
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: formKey,
        child: Column(
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
            const SizedBox(height: 20),
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

/// What should happen when you are updating the blog images?
/// if there's new image to be added, just append it to the existing images
///     
/// what will happen if the user delete an image,
///     You should have a list 