import 'package:flutter_blog_2/models/blog_user_model.dart';
import 'package:flutter_blog_2/models/comment_model.dart';

class BlogModel {
  BlogModel({
    required this.id,
    required this.title,
    required this.blog,
    required this.user,
    required this.imageUrls,
    required this.comments,
    required this.createdAt,
    this.loading = false,
  });
  final String? id;
  final String? title;
  final String? blog;
  final BlogUserModel? user;
  final bool loading;
  final List<String>? imageUrls;
  final List<CommentModel>? comments;
  final String? createdAt;

  factory BlogModel.initial() {
    return BlogModel(
      id: null,
      title: null,
      blog: null,
      user: null,
      comments: null,
      loading: false,
      imageUrls: null,
      createdAt: null,
    );
  }

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    if (json case {
      'id': final String id,
      'blog': final String blog,
      'title': final String title,
      'image_urls': final List<dynamic>? imageUrls,
      'created_at': final String createdAt,
      'user': final Map<String, dynamic> user,
    }) {
      return BlogModel(
        id: id,
        blog: blog,
        title: title,
        imageUrls: imageUrls != null
            ? imageUrls.map((img) => img as String).toList()
            : [],
        comments: [],
        createdAt: createdAt,
        user: BlogUserModel.formJson(user),
      );
    } else {
      throw const FormatException(
        'Unexpected JSON format (BlogModel.fromJson)',
      );
    }
  }

  BlogModel copyWith({
    String? id,
    String? title,
    String? blog,
    BlogUserModel? user,
    bool? loading,
    List<String>? imageUrls,
    String? createdAt,
    List<CommentModel>? comments,
  }) {
    return BlogModel(
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      comments: comments ?? this.comments,
      title: title ?? this.title,
      blog: blog ?? this.blog,
      user: user ?? this.user,
      loading: loading ?? this.loading,
    );
  }
}
