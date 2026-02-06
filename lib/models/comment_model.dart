import 'package:flutter_blog_2/models/blog_user_model.dart';

class CommentModel {
  CommentModel({
    required this.id,
    required this.comment,
    required this.user,
    required this.imageUrls,
    this.loading = false,
  });
  final String? id;
  final String? comment;
  final BlogUserModel? user;
  final bool loading;
  final List<String>? imageUrls;

  factory CommentModel.initial() {
    return CommentModel(
      id: null,
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
    bool? loading,
    List<String>? imageUrls,
  }) {
    return CommentModel(
      imageUrls: imageUrls ?? this.imageUrls,
      id: id ?? this.id,
      comment: comment ?? this.comment,
      user: user ?? this.user,
      loading: loading ?? this.loading,
    );
  }
}
