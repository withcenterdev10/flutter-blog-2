import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_blog_2/dio.dart';

enum ExtraAuthProperties { displayName }

enum Pages { profile, blogs }

enum Tables { blogs }

const int imageLimit = 3;

Future<String?> uploadImageToCloudinary(File? image) async {
  if (image == null) return null;

  try {
    final cloudName = dotenv.env['CLOUDINARY_NAME'];
    final updatePreset = dotenv.env['CLOUDINARY_PRESET'];

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      ),
      'upload_preset': updatePreset,
      'cloud_name': cloudName,
    });

    final response = await dio.post(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    if (response.statusCode == 200) {
      return response.data['url'] as String?;
    } else {
      throw Exception('Something went wrong while uploading the image');
    }
  } catch (e) {
    throw Exception(e);
  }
}

String truncateText(String text) {
  if (text.length < 30) {
    return text;
  }

  return '${text.substring(0, 30)}...';
}

String toUpperCaseFirstChar(String text) {
  return text.substring(0, 1).toUpperCase() + text.substring(1);
}
