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
  List<Uint8List>? selectedWebImages = [];
  bool isPickingImage = false;

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

  void handleAddImage(BuildContext context) async {
    setState(() {
      isPickingImage = true;
    });

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
      selectedWebImages = updatedSelectedWebImages;
      isPickingImage = false;
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

    final bottomInset =
        PlatformDispatcher.instance.views.first.viewInsets.bottom;
    final isVisible = bottomInset > 0;

    if (_keyboardVisible && !isVisible) {
      if (!isPickingImage) {
        context.read<CommentProvider>().resetState();
        commentController.text = "";
      }

      focusNode.unfocus();
      if (!commentState.isEditting) {
        commentController.text = "";

        setState(() {
          selectedBlogImages = [];
        });
      }
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
        final isNoSelectedImages =
            selectedImages == null ||
            (selectedImages != null && selectedImages!.isEmpty);

        final isNoSelectedWebImages =
            selectedWebImages == null ||
            (selectedWebImages != null && selectedWebImages!.isEmpty);

        final noExistingImages = selectedBlogImages.isEmpty;

        if (isNoSelectedImages &&
            isNoSelectedWebImages &&
            noExistingImages &&
            comment == "") {
          return;
        }

        if (commentState.isEditting) {
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

          returnedComment = await context.read<CommentProvider>().updateComment(
            commentId: commentState.id!,
            userId: authState.user!.id,
            comment: comment,
            newImages: selectedImages,
            newWebImages: selectedWebImages,
            networkImages: remainingPreviousImgUrls,
          );
        } else {
          returnedComment = await context.read<CommentProvider>().createComment(
            parentId: commentState.isToDeep
                ? commentState.parentId
                : commentState.id,
            blogId: blogState.id!,
            userId: authState.user!.id,
            comment: comment,
            images: selectedImages,
            newWebImages: selectedWebImages,
          );
        }
        commentController = TextEditingController();
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
        commentController.clear();
        focusNode.unfocus();

        setState(() {
          selectedImages = [];
          selectedWebImages = [];
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
    bool isDesktop = MediaQuery.of(context).size.width >= 900;

    void buildPreviewImage() {
      List<BlogImage> tempList = [];
      if (commentState.imageUrls != null) {
        for (var i = 0; i < commentState.imageUrls!.length; i++) {
          final imageUrl = commentState.imageUrls![i];
          final isExist = selectedBlogImages.contains((e) => e.id == imageUrl);
          if (!isExist) {
            tempList.add(
              BlogImage(
                id: imageUrl,
                networImage: imageUrl,
                onRemove: removeImage,
              ),
            );
          }
        }

        setState(() {
          selectedBlogImages = tempList;
        });
      }
    }

    if (commentState.id != null && !commentState.isDeleting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        focusNode.requestFocus();

        if (commentController.text != commentState.comment &&
            !commentState.loading &&
            commentState.isEditting) {
          commentController.text = commentState.comment;
          buildPreviewImage();
        }
      });
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: Column(
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
              4,
              4,
              4,
              (isDesktop ? 12 : 4) + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Form(
              key: formKey,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      handleAddImage(context);
                    },
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
