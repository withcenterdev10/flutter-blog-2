import 'package:flutter_blog_2/models/blog_user_model.dart';

class BlogModel {
  BlogModel({
    required this.id,
    required this.title,
    required this.blog,
    required this.user,
    this.loading = false,
  });
  final String? id;
  final String? title;
  final String? blog;
  final BlogUserModel? user;
  final bool loading;

  factory BlogModel.initial() {
    return BlogModel(
      id: null,
      title: null,
      blog: null,
      user: null,
      loading: false,
    );
  }

  BlogModel copyWith({
    String? id,
    String? title,
    String? blog,
    BlogUserModel? user,
    bool? loading,
  }) {
    return BlogModel(
      id: id ?? this.id,
      title: title ?? this.title,
      blog: blog ?? this.blog,
      user: user ?? this.user,
      loading: loading ?? this.loading,
    );
  }
}
