import 'package:flutter_blog_2/models/blog_user_model.dart';
import 'package:flutter_blog_2/utils.dart';

class CommentModel {
  CommentModel({
    required this.id,
    required this.comment,
    required this.user,
    required this.createdAt,
    required this.blogId,
    required this.parentId,
    required this.parentType,
    this.comments,
    this.imageUrls,
    this.loading = false,
  });
  final String? id;
  final String comment;
  final String? createdAt;
  final BlogUserModel user;
  final bool loading;
  final String blogId;
  final String parentId;
  final CommentParentType parentType;
  final List<CommentModel>? comments;
  final List<String>? imageUrls;

  factory CommentModel.initial() {
    return CommentModel(
      id: null,
      createdAt: null,
      comment: "",
      parentType: CommentParentType.blog,
      user: BlogUserModel(displayName: "", id: "", imageUrl: null),
      loading: false,
      imageUrls: null,
      blogId: "",
      parentId: "",
    );
  }

  CommentModel copyWith({
    String? id,
    String? comment,
    String? blog,
    String? blogId,
    BlogUserModel? user,
    String? createdAt,
    bool? loading,
    List<String>? imageUrls,
    String? parentId,
    CommentParentType? parentType,
  }) {
    return CommentModel(
      blogId: blogId ?? this.blogId,
      imageUrls: imageUrls ?? this.imageUrls,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      comment: comment ?? this.comment,
      user: user ?? this.user,
      loading: loading ?? this.loading,
      parentId: parentId ?? this.parentId,
      parentType: parentType ?? this.parentType,
    );
  }
}
