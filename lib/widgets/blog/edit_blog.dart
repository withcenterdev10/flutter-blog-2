import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/widgets/blog/blog_image.dart';
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
  List<Uint8List> selectedWebImages = [];

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
    var updatedSelectedWebImages = selectedWebImages;

    if (mobileImage != null) {
      updatedSelectedImages.insert(0, mobileImage);
    }

    if (webImage != null) {
      updatedSelectedWebImages.insert(0, webImage);
    }

    setState(() {
      selectedBlogImages = updatedImages;
      selectedImages = updatedSelectedImages;
      selectedWebImages = updatedSelectedWebImages;
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
            newWebImages: selectedWebImages,
            networkImages: remainingPreviousImgUrls,
          );
          message = "Update blog success";
        } catch (error) {
          message = "Update blog failed";
          debugPrint(error.toString());
          throw Exception("Update blog failed");
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

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Update Blog",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      autofocus: true,
                      maxLength: 50,
                      controller: titleController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
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
                      maxLines: 6,
                      controller: blogController,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        labelText: "Blog",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Blog content must not be empty';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),
                    const Divider(),

                    Row(
                      children: [
                        const Text("Upload images"),
                        const Spacer(),
                        IconButton(
                          onPressed: handleAddImage,
                          icon: const Icon(Icons.add_a_photo, size: 20),
                        ),
                      ],
                    ),

                    if (selectedBlogImages.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: selectedBlogImages.length,
                          itemBuilder: (context, index) =>
                              selectedBlogImages[index],
                        ),
                      ),

                    const SizedBox(height: 16),

                    SizedBox(
                      child: ElevatedButton(
                        onPressed: onSubmit,
                        child: blogState.loading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
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
          ),
        ),
      ),
    );
  }
}
