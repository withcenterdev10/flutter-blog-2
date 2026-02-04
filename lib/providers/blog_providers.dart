import 'package:flutter/material.dart';
import 'package:flutter_blog_2/db.dart';
import 'package:flutter_blog_2/models/blog_model.dart';
import 'package:flutter_blog_2/models/blog_user_model.dart';
import 'package:flutter_blog_2/models/blogs_model.dart';
import 'package:flutter_blog_2/utils.dart';

class BlogProvider extends ChangeNotifier {
  BlogModel blog = BlogModel.initial();
  BlogsModel blogs = BlogsModel.initial();

  BlogProvider() {
    getBlogs();
  }

  BlogModel get getBlogState {
    return blog;
  }

  BlogsModel get getBlogsState {
    return blogs;
  }

  BlogModel _setBlogState(BlogModel newState) {
    blog = newState;
    notifyListeners();
    return blog;
  }

  void _setBlogsState(BlogsModel newState) {
    blogs = newState;
    notifyListeners();
  }

  Future<void> updateBlog({
    final String? id,
    final String? title,
    final String? blog,
    final String? userId,
  }) async {
    _setBlogState(getBlogState.copyWith(loading: true));
    try {
      final res = await supabase
          .from(Tables.blogs.name)
          .update({'title': title, 'blog': blog, 'user_id': userId})
          .eq("id", id!)
          .select(
            "id, title, created_at, blog, user: profiles (id, display_name, image_url)",
          )
          .single();

      final newBlog = _setBlogState(
        getBlogState.copyWith(
          id: res['id'],
          blog: res['blog'],
          title: res['title'],
          user: BlogUserModel(
            id: res['user']['id'],
            imageUrl: res['user']['image_url'],
            displayName: res['user']['display_name'],
          ),
        ),
      );

      final updatedBlogs = blogs.updateBlog(newBlog);
      _setBlogsState(getBlogsState.copyWith(blogs: updatedBlogs));
    } catch (err) {
      debugPrint(err.toString());
    } finally {
      _setBlogState(getBlogState.copyWith(loading: false));
    }
  }

  Future<void> deleteBlog({final String? id, final String? userId}) async {
    _setBlogState(getBlogState.copyWith(loading: true));
    try {
      await supabase
          .from(Tables.blogs.name)
          .update({'user_id': userId, 'is_deleted': true})
          .eq("id", id!);

      final updatedBlogs = blogs.deleteBlog(id);
      _setBlogsState(getBlogsState.copyWith(blogs: updatedBlogs));
    } catch (err) {
      debugPrint(err.toString());
    } finally {
      _setBlogState(getBlogState.copyWith(loading: false));
    }
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
          .select(
            "id, title, created_at, blog, user: profiles (id, display_name, image_url)",
          )
          .single();

      final newBlog = _setBlogState(
        getBlogState.copyWith(
          id: res['id'],
          blog: res['blog'],
          title: res['title'],
          user: BlogUserModel(
            id: res['user']['id'],
            imageUrl: res['user']['image_url'],
            displayName: res['user']['display_name'],
          ),
        ),
      );

      final updatedBlogs = blogs.addBlog(newBlog);
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
          .select(
            "id, title, created_at, blog, user: profiles (id, display_name, image_url)",
          )
          .eq("is_deleted", false);

      final myBlogs = [
        for (var i = 0; i < res.length - 1; i++)
          BlogModel(
            id: res[i]['id'],
            title: res[i]['title'],
            blog: res[i]['blog'],
            user: BlogUserModel(
              id: res[i]['user']['id'],
              imageUrl: res[i]['user']['image_url'],
              displayName: res[i]['user']['display_name'],
            ),
          ),
      ];

      _setBlogsState(blogs.copyWith(blogs: myBlogs));
    } catch (err) {
      debugPrint(err.toString());
    } finally {
      _setBlogState(getBlogState.copyWith(loading: false));
    }
  }

  Future<void> getBlog(String id) async {
    _setBlogState(getBlogState.copyWith(loading: true));
    try {
      if (blog.id == id) {
        return;
      }

      final res = await supabase
          .from(Tables.blogs.name)
          .select(
            "id, title, created_at, blog, user: profiles (id, display_name, image_url)",
          )
          .eq("is_deleted", false)
          .eq('id', id)
          .single();

      _setBlogState(
        getBlogState.copyWith(
          id: res['id'],
          blog: res['blog'],
          title: res['title'],
          user: BlogUserModel(
            id: res['user']['id'],
            imageUrl: res['user']['image_url'],
            displayName: res['user']['display_name'],
          ),
        ),
      );
    } catch (err) {
      debugPrint(err.toString());
    } finally {
      _setBlogState(getBlogState.copyWith(loading: false));
    }
  }
}
