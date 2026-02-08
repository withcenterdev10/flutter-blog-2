import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blog_2/db.dart';
import 'package:flutter_blog_2/models/blog_model.dart';
import 'package:flutter_blog_2/models/blog_user_model.dart';
import 'package:flutter_blog_2/models/blogs_model.dart';
import 'package:flutter_blog_2/models/comment_model.dart';
import 'package:flutter_blog_2/providers/comment_provider.dart';
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
        myBlogs.add(BlogModel.fromJson(res[i]));
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
      List<CommentModel> comments = [];
      List<String> rootCommentIds = [];

      final res = await supabase
          .from(Tables.blogs.name)
          .select(
            "id, title, created_at, blog, image_urls, user: profiles (id, display_name, image_url)",
          )
          .eq("is_deleted", false)
          .eq('id', id)
          .single();

      final rootComments = await CommentProvider.getFirstLevelComments(
        blogId: id,
      );

      if (rootComments.isNotEmpty) {
        rootCommentIds = rootComments.map((c) {
          return c['id'] as String;
        }).toList();
      }

      if (rootCommentIds.isNotEmpty) {
        final childrenComments =
            await CommentProvider.getCommentsUsingParentIds(
              parentIds: rootCommentIds,
            );

        comments = CommentProvider.buildRootComments(
          rootComments,
          childrenComments,
        );
      }

      _setBlogState(BlogModel.fromJson(res).copyWith(comments: comments));
    } catch (err) {
      debugPrint(err.toString());
    } finally {
      _setBlogState(getBlogState.copyWith(loading: false));
    }
  }
}
