import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blog_2/dio.dart';
import 'package:flutter/material.dart';

enum ExtraAuthProperties { displayName }

enum Pages { profile, blogs, comments }

enum Tables { blogs }

enum CommentParentType { blog, comment }

final GlobalKey<ScaffoldState> sharedScaffoldKey = GlobalKey<ScaffoldState>();

const int imageLimit = 3;

Future<String> uploadImageToCloudinary({
  File? image,
  Uint8List? webImage,
}) async {
  try {
    final cloudName = String.fromEnvironment('CLOUDINARY_PRESET');
    final updatePreset = String.fromEnvironment('CLOUDINARY_NAME');

    late MultipartFile multipartFile;

    if (webImage != null) {
      multipartFile = MultipartFile.fromBytes(webImage, filename: "upload.jpg");
    }

    if (image != null) {
      multipartFile = await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      );
    }

    final formData = FormData.fromMap({
      'file': multipartFile,
      'upload_preset': updatePreset,
      'cloud_name': cloudName,
    });

    final response = await dio.post(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    if (response.statusCode == 200) {
      return response.data['url'];
    } else {
      throw Exception('Something went wrong while uploading the image');
    }
  } catch (e) {
    throw Exception(e);
  }
}

String truncateText(String text, {int limit = 30}) {
  if (text.length < limit) {
    return text;
  }

  return '${text.substring(0, 30)}...';
}

String toUpperCaseFirstChar(String text) {
  return text.substring(0, 1).toUpperCase() + text.substring(1);
}

String timeAgo(String timeStamp) {
  final now = DateTime.now();
  final diff = now.difference(DateTime.parse(timeStamp));

  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
  if (diff.inHours < 24) return '${diff.inHours} hours ago';
  if (diff.inDays < 7) return '${diff.inDays} days ago';

  return '${(diff.inDays / 7).floor()} weeks ago';
}
