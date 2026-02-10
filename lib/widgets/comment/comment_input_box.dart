import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_blog_2/models/comment_model.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/providers/comment_provider.dart';
import 'package:flutter_blog_2/widgets/blog/blog_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CommentInput extends StatefulWidget {
  const CommentInput({super.key});

  @override
  State<CommentInput> createState() {
    return _CommentInputState();
  }
}

class _CommentInputState extends State<CommentInput>
    with WidgetsBindingObserver {
  final formKey = GlobalKey<FormState>();
  late TextEditingController commentController;
  bool _keyboardVisible = false;
  final focusNode = FocusNode();
  File? selectedImage;
  String? selectedImagePath;
  List<BlogImage> selectedBlogImages = [];
  List<File>? selectedImages = [];

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
      updatedSelectedImages?.add(mobileImage);
    }

    setState(() {
      selectedBlogImages = updatedImages;
      selectedImages = updatedSelectedImages;
    });
  }

  @override
  void initState() {
    super.initState();
    commentController = TextEditingController();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    focusNode.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final commentState = context.read<CommentProvider>().getState;

    if (commentState.id != null) {
      focusNode.requestFocus();
    }

    if (commentState.isEditting) {
      commentController = TextEditingController(text: commentState.comment);
    }

    final bottomInset =
        PlatformDispatcher.instance.views.first.viewInsets.bottom;
    final isVisible = bottomInset > 0;

    if (_keyboardVisible && !isVisible) {
      context.read<CommentProvider>().resetState();
      focusNode.unfocus();
      commentController = TextEditingController();
    }

    _keyboardVisible = isVisible;
  }

  void onSubmit(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      final authState = context.read<AuthProvider>().getState;
      final blogState = context.read<BlogProvider>().getBlogState;
      final commentState = context.read<CommentProvider>().getState;

      final comment = commentController.text;
      try {
        CommentModel returnedComment;

        if (commentState.isEditting) {
          returnedComment = await context.read<CommentProvider>().updateComment(
            commentId: commentState.id!,
            userId: authState.user!.id,
            comment: comment,
            image: selectedImage,
            existingImageUrls: commentState.imageUrls,
          );
        } else {
          returnedComment = await context.read<CommentProvider>().createComment(
            parentId: commentState.id,
            blogId: blogState.id!,
            userId: authState.user!.id,
            comment: comment,
            images: selectedImages,
          );
        }

        if (context.mounted) {
          if (commentState.isEditting) {
            context.read<BlogProvider>().updateComment(returnedComment);
            context.read<CommentProvider>().resetState();
          } else {
            context.read<BlogProvider>().insertComment(returnedComment);
          }
        }
      } catch (error) {
        debugPrint(error.toString());
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Comment failed")));
        }
      } finally {
        formKey.currentState!.reset();
        focusNode.unfocus();

        setState(() {
          selectedImages = [];
          selectedBlogImages = [];
        });
        if (context.mounted) {
          context.read<CommentProvider>().resetState();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentState = context.watch<CommentProvider>().getState;

    if (commentState.id != null && !commentState.isDeleting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        focusNode.requestFocus();
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (selectedBlogImages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SizedBox(
              height: 70,
              width: double.infinity,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: selectedBlogImages.length,
                itemBuilder: (BuildContext context, int index) =>
                    selectedBlogImages[index],
              ),
            ),
          ),
        Padding(
          padding: EdgeInsetsGeometry.fromLTRB(
            8,
            4,
            8,
            4 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: formKey,
            child: Row(
              children: [
                IconButton(
                  onPressed: handleAddImage,
                  icon: Icon(Icons.camera_alt),
                ),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextFormField(
                      focusNode: focusNode,
                      controller: commentController,
                      decoration: InputDecoration(
                        labelText: "Comment",
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.all(8.0),
                        suffixIconConstraints: BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        suffixIcon: commentState.loading
                            ? Padding(
                                padding: EdgeInsets.all(10),
                                child: SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : IconButton(
                                onPressed: () {
                                  onSubmit(context);
                                },
                                icon: Icon(Icons.send),
                              ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Type your comment';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
