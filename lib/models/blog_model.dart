import 'package:flutter_blog_2/models/blog_user_model.dart';

class BlogModel {
  BlogModel({
    required this.id,
    required this.title,
    required this.blog,
    required this.user,
    required this.imageUrls,
    this.loading = false,
  });
  final String? id;
  final String? title;
  final String? blog;
  final BlogUserModel? user;
  final bool loading;
  final List<String>? imageUrls;

  factory BlogModel.initial() {
    return BlogModel(
      id: null,
      title: null,
      blog: null,
      user: null,
      loading: false,
      imageUrls: null,
    );
  }

  BlogModel copyWith({
    String? id,
    String? title,
    String? blog,
    BlogUserModel? user,
    bool? loading,
    List<String>? imageUrls,
  }) {
    return BlogModel(
      imageUrls: imageUrls ?? this.imageUrls,
      id: id ?? this.id,
      title: title ?? this.title,
      blog: blog ?? this.blog,
      user: user ?? this.user,
      loading: loading ?? this.loading,
    );
  }
}
