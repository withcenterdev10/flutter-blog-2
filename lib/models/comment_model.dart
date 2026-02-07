import 'package:flutter_blog_2/models/blog_user_model.dart';

class CommentModel {
  CommentModel({
    required this.id,
    required this.comment,
    required this.user,
    required this.imageUrls,
    required this.createdAt,
    this.loading = false,
  });
  final String? id;
  final String? comment;
  final String? createdAt;
  final BlogUserModel? user;
  final bool loading;
  final List<String>? imageUrls;

  factory CommentModel.initial() {
    return CommentModel(
      id: null,
      createdAt: null,
      comment: null,
      user: null,
      loading: false,
      imageUrls: null,
    );
  }

  CommentModel copyWith({
    String? id,
    String? comment,
    String? blog,
    BlogUserModel? user,
    String? createdAt,
    bool? loading,
    List<String>? imageUrls,
  }) {
    return CommentModel(
      imageUrls: imageUrls ?? this.imageUrls,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      comment: comment ?? this.comment,
      user: user ?? this.user,
      loading: loading ?? this.loading,
    );
  }
}
