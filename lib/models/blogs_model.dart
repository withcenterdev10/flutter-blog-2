import 'package:flutter_blog_2/models/blog_model.dart';

class BlogsModel {
  BlogsModel({required this.blogs, this.loading = false});

  final List<BlogModel>? blogs;
  final bool loading;

  factory BlogsModel.initial() {
    return BlogsModel(blogs: null, loading: false);
  }

  BlogsModel copyWith({List<BlogModel>? blogs, bool? loading}) {
    return BlogsModel(
      blogs: blogs ?? this.blogs,
      loading: loading ?? this.loading,
    );
  }
}
