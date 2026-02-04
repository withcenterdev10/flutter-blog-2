import 'package:flutter_blog_2/models/blog_model.dart';
import 'package:flutter_blog_2/models/blog_user_model.dart';

class BlogsModel {
  BlogsModel({required this.blogs, this.loading = false, required this.user});

  final List<BlogModel> blogs;
  final BlogUserModel? user;
  final bool loading;

  factory BlogsModel.initial() {
    return BlogsModel(blogs: [], loading: false, user: null);
  }

  BlogsModel copyWith({
    List<BlogModel>? blogs,
    bool? loading,
    BlogUserModel? user,
  }) {
    return BlogsModel(
      blogs: blogs ?? this.blogs,
      loading: loading ?? this.loading,
      user: user ?? this.user,
    );
  }

  List<BlogModel> addBlog(BlogModel blog) {
    blogs.insert(0, blog);
    return blogs;
  }

  List<BlogModel> updateBlog(BlogModel blog) {
    final updatedBlog = blogs.map((b) {
      if (blog.id == b.id) {
        return blog;
      } else {
        return b;
      }
    }).toList();

    return updatedBlog;
  }
}
