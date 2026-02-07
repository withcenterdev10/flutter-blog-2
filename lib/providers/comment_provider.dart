import 'package:flutter/foundation.dart';
import 'package:flutter_blog_2/db.dart';
import 'package:flutter_blog_2/models/comment_model.dart';
import 'package:flutter_blog_2/utils.dart';

class CommentProvider extends ChangeNotifier {
  CommentModel state = CommentModel.initial();

  CommentModel get getState {
    return state;
  }

  void setState(CommentModel newState) {
    state = newState;
    notifyListeners();
  }

  void resetState() {
    state = CommentModel.initial();
    notifyListeners();
  }

  Future<void> createComment({
    required String parentId,
    required String blogId,
    required String userId,
    String? comment,
    List<String>? imageUrls,
  }) async {
    setState(state.copyWith(loading: true));
    try {
      // final res = await supabase.Comment.getUser();
      // setState(state.copyWith(user: res.user));
      // final now = DateTime.now().toIso8601String();
      final res = await supabase
          .from(Pages.comments.name)
          .insert({
            'parent_id': parentId,
            'blog_id': blogId,
            'comment': comment,
            'user_id': userId,
            'image_urls': [],
          })
          .select(
            "id, blog_id, parent_id, comment, created_at, image_urls, user: profiles (id, display_name, image_url)",
          )
          .single();

      setState(state.copyWith(loading: false));
    } catch (err) {
      debugPrint(err.toString());
      throw Exception('Create comment failed');
    } finally {
      setState(state.copyWith(loading: false));
    }
  }
}
