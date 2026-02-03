import 'package:flutter/material.dart';
import 'package:flutter_blog_2/db.dart';
import 'package:flutter_blog_2/models/blog_model.dart';
import 'package:flutter_blog_2/utils.dart';

class BlogProviders extends ChangeNotifier {
  BlogModel state = BlogModel.initial();

  BlogModel get getState {
    return state;
  }

  void _setState(BlogModel newState) {
    state = newState;
    notifyListeners();
  }

  Future<void> createBlog({
    final String? title,
    final String? blog,
    final String? userId,
  }) async {
    _setState(state.copyWith(loading: true));
    try {
      final res = await supabase
          .from(Tables.blogs.name)
          .insert({'title': title, 'blog': blog, 'user_id': userId})
          .select("id, title, created_at, blog")
          .single();

      _setState(
        state.copyWith(
          blog: res['blog'],
          title: res['title'],
          userId: res['user_id'],
        ),
      );
    } catch (err) {
      debugPrint(err.toString());
    } finally {
      _setState(state.copyWith(loading: false));
    }
  }
}
