import 'package:flutter/material.dart';
import 'package:flutter_blog_2/db.dart';
import 'package:flutter_blog_2/models/blog_model.dart';
import 'package:flutter_blog_2/models/blogs_model.dart';
import 'package:flutter_blog_2/utils.dart';

class BlogProviders extends ChangeNotifier {
  BlogModel blog = BlogModel.initial();
  BlogsModel blogs = BlogsModel.initial();

  BlogProviders() {
    getBlogs();
  }

  BlogModel get getBlogState {
    return blog;
  }

  BlogsModel get getBlogsState {
    return blogs;
  }

  void _setBlogState(BlogModel newState) {
    blog = newState;
    notifyListeners();
  }

  void _setBlogsState(BlogsModel newState) {
    blogs = newState;
    notifyListeners();
  }

  Future<void> createBlog({
    final String? title,
    final String? blog,
    final String? userId,
  }) async {
    _setBlogState(getBlogState.copyWith(loading: true));
    try {
      final res = await supabase
          .from(Tables.blogs.name)
          .insert({'title': title, 'blog': blog, 'user_id': userId})
          .select("id, title, created_at, blog")
          .single();

      _setBlogState(
        getBlogState.copyWith(
          blog: res['blog'],
          title: res['title'],
          userId: res['user_id'],
        ),
      );

      final updatedBlogs = blogs.addBlog(
        BlogModel(
          blog: res['blog'],
          title: res['title'],
          userId: res['user_id'],
        ),
      );

      _setBlogsState(getBlogsState.copyWith(blogs: updatedBlogs));
    } catch (err) {
      debugPrint(err.toString());
    } finally {
      _setBlogState(getBlogState.copyWith(loading: false));
    }
  }

  Future<void> getBlogs() async {
    try {
      final res = await supabase
          .from(Tables.blogs.name)
          .select("*")
          .eq("is_deleted", false);

      final myBlogs = [
        for (var i = 0; i < res.length - 1; i++)
          BlogModel(
            title: res[i]['blog'],
            blog: res[i]['blog'],
            userId: res[i]['user_id'],
          ),
      ];

      _setBlogsState(blogs.copyWith(blogs: myBlogs));
    } catch (err) {
      debugPrint(err.toString());
    } finally {
      _setBlogState(getBlogState.copyWith(loading: false));
    }
  }
}
