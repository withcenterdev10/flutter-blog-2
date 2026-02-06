import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blog_2/db.dart';
import 'package:flutter_blog_2/models/blog_model.dart';
import 'package:flutter_blog_2/models/blog_user_model.dart';
import 'package:flutter_blog_2/models/blogs_model.dart';
import 'package:flutter_blog_2/models/comment_model.dart';
import 'package:flutter_blog_2/utils.dart';

const blogLimit = 6;

class BlogProvider extends ChangeNotifier {
  BlogModel blog = BlogModel.initial();
  BlogsModel blogs = BlogsModel.initial();

  BlogProvider() {
    getBlogs(null);
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

  void resetBlogState() {
    _setBlogState(BlogModel.initial());
  }

  void _setBlogsState(BlogsModel newState) {
    blogs = newState;
    notifyListeners();
  }

  Future<void> updateBlog({
    required String id,
    final String? title,
    final String? blogContent,
    final String? userId,
    final List<File>? newImages,
    final List<String>? networkImages,
  }) async {
    _setBlogState(getBlogState.copyWith(loading: true));
    try {
      List<String> imageUrls = [];
      if (newImages != null && newImages.isNotEmpty) {
        List<Future<String>> futures = newImages
            .map((img) => uploadImageToCloudinary(img))
            .toList();
        imageUrls = await Future.wait(futures);
      }

      final images = [...?networkImages, ...imageUrls];

      final res = await supabase
          .from(Tables.blogs.name)
          .update({
            'title': title,
            'blog': blogContent,
            'user_id': userId,
            'image_urls': images,
          })
          .eq("id", id)
          .select(
            "id, title, created_at, blog, image_urls, user: profiles (id, display_name, image_url)",
          )
          .single();

      List<String> imgUrls = [];
      if (res['image_urls'] != null) {
        imgUrls = [...res['image_urls']];
      }

      final newBlog = _setBlogState(
        getBlogState.copyWith(
          id: res['id'],
          blog: res['blog'],
          title: res['title'],
          imageUrls: imgUrls,
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
    final List<File>? images,
  }) async {
    _setBlogState(getBlogState.copyWith(loading: true));
    try {
      List<dynamic>? imageUrls;

      if (images != null && images.isNotEmpty) {
        List<Future<dynamic>> futures = images
            .map((img) => uploadImageToCloudinary(img))
            .toList();
        imageUrls = await Future.wait(futures);
      }

      final res = await supabase
          .from(Tables.blogs.name)
          .insert({
            'title': title,
            'blog': blog,
            'user_id': userId,
            'image_urls': ?imageUrls,
          })
          .select(
            "id, title, created_at, blog, image_urls, user: profiles (id, display_name, image_url)",
          )
          .single();

      List<String> imgUrls = [];
      if (res['image_urls'] != null) {
        imgUrls = [...res['image_urls']];
      }

      final newBlog = _setBlogState(
        getBlogState.copyWith(
          id: res['id'],
          blog: res['blog'],
          title: res['title'],
          imageUrls: imgUrls,
          user: BlogUserModel(
            id: res['user']['id'],
            imageUrl: res['user']['image_url'],
            displayName: res['user']['display_name'],
          ),
        ),
      );

      final updatedBlogs = blogs.addBlog(newBlog);
      _setBlogsState(getBlogsState.copyWith(blogs: updatedBlogs));
      return res['id'];
    } catch (err) {
      debugPrint(err.toString());
      rethrow;
    } finally {
      _setBlogState(getBlogState.copyWith(loading: false));
    }
  }

  Future<void> getBlogs(String? userId) async {
    _setBlogsState(getBlogsState.copyWith(loading: true));
    try {
      late List<Map<String, dynamic>> res;
      if (userId == null) {
        res = await supabase
            .from(Tables.blogs.name)
            .select(
              "id, title, created_at, blog, image_urls, user: profiles (id, display_name, image_url)",
            )
            .eq("is_deleted", false)
            .limit(blogLimit)
            .order('created_at', ascending: false);
      } else {
        res = await supabase
            .from(Tables.blogs.name)
            .select(
              "id, title, created_at, blog, image_urls, user: profiles (id, display_name, image_url)",
            )
            .eq("is_deleted", false)
            .eq("user_id", userId)
            .limit(blogLimit)
            .order('created_at', ascending: false);
      }

      List<BlogModel> myBlogs = [];

      for (var i = 0; i < res.length; i++) {
        List<String> imageUrls = [];
        if (res[i]['image_urls'] != null) {
          imageUrls = [...res[i]['image_urls']];
        }
        myBlogs.add(
          BlogModel(
            id: res[i]['id'],
            title: res[i]['title'],
            blog: res[i]['blog'],
            imageUrls: imageUrls,
            comments: null,
            user: BlogUserModel(
              id: res[i]['user']['id'],
              imageUrl: res[i]['user']['image_url'],
              displayName: res[i]['user']['display_name'],
            ),
          ),
        );
      }

      _setBlogsState(blogs.copyWith(blogs: myBlogs));
    } catch (err) {
      debugPrint(err.toString());
    } finally {
      _setBlogsState(getBlogsState.copyWith(loading: false));
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
            "id, title, created_at, blog, image_urls, user: profiles (id, display_name, image_url), comments (id, blog_id, user_id, comment, image_urls, created_at, updated_at, parent_id, user: profiles (id, display_name, image_url))",
          )
          .eq("is_deleted", false)
          .eq('id', id)
          .single();

      List<CommentModel> comments = [];
      List<String> commentImageUrls = [];
      List<String> blogImageUrls = [];

      if (res['image_urls'] != null) {
        blogImageUrls = [...res['image_urls']];
      }

      if (res['comments'] != null) {
        final myComments = res['comments'];

        // not good, change this later
        for (var k = 0; k < myComments.length; k++) {
          final comment = myComments[k];

          if (comment['image_urls'] != null) {
            commentImageUrls = [...comment['image_urls']];
          }

          comments.add(
            CommentModel(
              id: comment['id'],
              comment: comment['comment'],
              user: BlogUserModel(
                id: comment['user']['id'],
                imageUrl: comment['user']['image_url'],
                displayName: comment['user']['display_name'],
              ),
              imageUrls: commentImageUrls,
            ),
          );
        }
      }

      _setBlogState(
        getBlogState.copyWith(
          id: res['id'],
          blog: res['blog'],
          title: res['title'],
          imageUrls: blogImageUrls,
          comments: comments,
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
