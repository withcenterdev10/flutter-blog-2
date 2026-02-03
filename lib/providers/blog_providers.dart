import 'package:flutter/material.dart';
import 'package:flutter_blog_2/models/blog_model.dart';

class BlogProviders extends ChangeNotifier {
  BlogModel state = BlogModel.initial();

  BlogModel get getState {
    return state;
  }

  void _setState(BlogModel newState) {
    state = newState;
    notifyListeners();
  }

  Future<void> createBlog() async {
    _setState(state.copyWith(loading: true));
    try {
      // insert blog to supabase
    } catch (err) {
      debugPrint(err.toString());
    } finally {
      _setState(state.copyWith(loading: false));
    }
  }
}
