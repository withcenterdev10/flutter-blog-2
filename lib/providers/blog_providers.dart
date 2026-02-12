import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blog_2/db.dart';
import 'package:flutter_blog_2/models/blog_model.dart';
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

  void _setBlogState(BlogModel newState) {
    blog = newState;
    notifyListeners();
  }

  void deleteComment(CommentModel comment) {
    if (blog.comments != null && blog.comments!.isNotEmpty) {
      final updatedComments = blog.comments!
          .map((com) => findCommentAndDelete(com, comment))
          .where((com) => com != null)
          .cast<CommentModel>()
          .toList();
      _setBlogState(blog.copyWith(comments: [...updatedComments]));
    }
  }

  CommentModel? findCommentAndDelete(
    CommentModel comment,
    CommentModel toDeleteComment,
  ) {
    if (comment.id == toDeleteComment.id) {
      return null;
    }

    if (comment.comments != null && comment.comments!.isNotEmpty) {
      final updatedComments = comment.comments!
          .map((com) => findCommentAndDelete(com, toDeleteComment))
          .where((com) => com != null)
          .cast<CommentModel>()
          .toList();

      return comment.copyWith(comments: [...updatedComments]);
    }

    return comment;
  }

  void updateComment(CommentModel comment) {
    if (blog.comments == null || blog.comments!.isEmpty) return;

    final updatedComments = blog.comments!
        .map((com) => findCommentAndUpdate(com, comment))
        .toList();

    _setBlogState(blog.copyWith(comments: updatedComments));
  }

  CommentModel findCommentAndUpdate(
    CommentModel comment,
    CommentModel toUpdateComment,
  ) {
    if (comment.id == toUpdateComment.id) {
      return toUpdateComment.copyWith(comments: comment.comments);
    }

    if (comment.comments != null && comment.comments!.isNotEmpty) {
      final updatedChildren = comment.comments!
          .map((c) => findCommentAndUpdate(c, toUpdateComment))
          .toList();

      return comment.copyWith(comments: updatedChildren);
    }

    return comment;
  }

  void insertComment(CommentModel comment) {
    // insert the comment as root comment if theres no parent id
    if (comment.parentId == null) {
      _setBlogState(
        blog.copyWith(
          comments: blog.comments != null
              ? [...blog.comments!, comment]
              : [comment],
        ),
      );
      return;
    }

    // other wise, find the parent comment first, once found insert as one of the child comment
    List<CommentModel>? updatedComments = blog.comments;
    if (blog.comments != null && blog.comments!.isNotEmpty) {
      updatedComments = blog.comments!.map((com) {
        return findParentCommentAndInsert(com, comment);
      }).toList();
    }

    _setBlogState(blog.copyWith(comments: updatedComments));
  }

  CommentModel findParentCommentAndInsert(
    CommentModel comment,
    CommentModel toInsertComment,
  ) {
    if (comment.id == toInsertComment.parentId) {
      return comment.copyWith(
        comments: comment.comments != null
            ? [...comment.comments!, toInsertComment]
            : [toInsertComment],
      );
    }

    if (comment.comments != null && comment.comments!.isNotEmpty) {
      final updatedComments = comment.comments!.map((com) {
        return findParentCommentAndInsert(com, toInsertComment);
      }).toList();

      return comment.copyWith(comments: [...updatedComments]);
    }

    return comment;
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
    final List<Uint8List>? newWebImages,
    final List<String>? networkImages,
  }) async {
    _setBlogState(getBlogState.copyWith(loading: true));
    try {
      List<String> imageUrls = [];
      if (newImages != null && newImages.isNotEmpty) {
        List<Future<String>> futures = newImages
            .map((img) => uploadImageToCloudinary(image: img))
            .toList();
        imageUrls = await Future.wait(futures);
      }

      if (newWebImages != null && newWebImages.isNotEmpty) {
        List<Future<String>> futures = newWebImages
            .map((img) => uploadImageToCloudinary(webImage: img))
            .toList();
        imageUrls = await Future.wait(futures);
      }

      final images = [...?networkImages, ...imageUrls];
      final now = DateTime.now().toIso8601String();
      final res = await supabase
          .from(Tables.blogs.name)
          .update({
            'title': title,
            'blog': blogContent,
            'user_id': userId,
            'image_urls': images,
            'updated_at': now,
          })
          .eq("id", id)
          .select(
            "id, title, created_at, blog, image_urls, user: profiles (id, display_name, image_url)",
          )
          .single();

      final updatedBlog = BlogModel.fromJson(res);
      _setBlogState(updatedBlog);
      final updatedBlogs = blogs.updateBlog(updatedBlog);
      _setBlogsState(getBlogsState.copyWith(blogs: updatedBlogs));
    } catch (err) {
      debugPrint(err.toString());
      rethrow;
    } finally {
      _setBlogState(getBlogState.copyWith(loading: false));
    }
  }

  Future<void> deleteBlog({final String? id, final String? userId}) async {
    _setBlogState(getBlogState.copyWith(loading: true));
    try {
      final now = DateTime.now().toIso8601String();
      await supabase
          .from(Tables.blogs.name)
          .update({'user_id': userId, 'is_deleted': true, 'deleted_at': now})
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
    final List<Uint8List>? webImages,
  }) async {
    _setBlogState(getBlogState.copyWith(loading: true));
    try {
      List<dynamic>? imageUrls;

      if (images != null && images.isNotEmpty) {
        List<Future<String>> futures = images
            .map((img) => uploadImageToCloudinary(image: img))
            .toList();
        imageUrls = await Future.wait(futures);
      }

      if (webImages != null && webImages.isNotEmpty) {
        List<Future<String>> futures = webImages
            .map((img) => uploadImageToCloudinary(webImage: img))
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

      final newBlog = BlogModel.fromJson(res);
      _setBlogState(newBlog);
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
      List<String> secondLevelIds = [];

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
        final secondLevelComments =
            await CommentProvider.getCommentsUsingParentIds(
              parentIds: rootCommentIds,
            );

        if (secondLevelComments.isNotEmpty) {
          secondLevelIds = secondLevelComments.map((c) {
            return c['id'] as String;
          }).toList();
        }

        final thirdLevelComments =
            await CommentProvider.getCommentsUsingParentIds(
              parentIds: secondLevelIds,
            );

        comments = CommentProvider.buildRootComments(rootComments, [
          ...secondLevelComments,
          ...thirdLevelComments,
        ]);
      }

      _setBlogState(BlogModel.fromJson(res).copyWith(comments: comments));
    } catch (err) {
      debugPrint(err.toString());
    } finally {
      _setBlogState(getBlogState.copyWith(loading: false));
    }
  }
}
