import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/screens/view_blog_screen.dart';
import 'package:flutter_blog_2/widgets/blog/blog_image.dart';
import 'package:flutter_blog_2/widgets/submit_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  List<Uint8List>? selectedWebImages = [];

  void removeImage(String imageId) {
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

    if (image == null) {
      return (mobileImage: null, webImage: null);
    }

    // mobile
    if (!kIsWeb) {
      mobileImage = File(image.path);
    } else {
      // web
      webImage = await image.readAsBytes();
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
      updatedSelectedImages?.add(mobileImage);
    }

    if (webImage != null) {
      updatedSelectedWebImages?.add(webImage);
    }

    setState(() {
      selectedBlogImages = updatedImages;
      selectedImages = updatedSelectedImages;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select<BlogProvider, bool>(
      (p) => p.getBlogState.loading,
    );

    void onSubmit() async {
      if (formKey.currentState!.validate()) {
        final userState = context.read<AuthProvider>().getState;
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
            webImages: selectedWebImages,
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

    return SafeArea(
      child: Align(
        alignment: .topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: .max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Add new blog",
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
                          return 'Blog must not be empty';
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
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          scrollDirection: Axis.horizontal,
                          itemCount: selectedBlogImages.length,
                          itemBuilder: (context, index) =>
                              selectedBlogImages[index],
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: SubmitButton(onSubmit: onSubmit, loading: loading),
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
