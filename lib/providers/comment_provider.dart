import 'package:flutter/foundation.dart';
import 'package:flutter_blog_2/db.dart';
import 'package:flutter_blog_2/models/comment_model.dart';
import 'package:flutter_blog_2/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<CommentModel> createComment({
    required String? parentId,
    required String blogId,
    required String userId,
    String? comment,
    List<String>? imageUrls,
  }) async {
    setState(state.copyWith(loading: true));
    try {
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
      return CommentModel.fromJson(res);
    } catch (err) {
      debugPrint(err.toString());
      throw Exception('Create comment failed');
    } finally {
      setState(state.copyWith(loading: false));
    }
  }

  Future<CommentModel> updateComment({
    required String commentId,
    required String userId,
    String? comment,
    List<String>? imageUrls,
  }) async {
    setState(state.copyWith(loading: true));
    try {
      final res = await supabase
          .from(Pages.comments.name)
          .update({'comment': comment, 'user_id': userId, 'image_urls': []})
          .eq("id", commentId)
          .select(
            "id, blog_id, parent_id, comment, created_at, image_urls, user: profiles (id, display_name, image_url)",
          )
          .single();

      setState(state.copyWith(loading: false));
      return CommentModel.fromJson(res);
    } catch (err) {
      debugPrint(err.toString());
      throw Exception('Update comment failed');
    } finally {
      setState(state.copyWith(loading: false));
    }
  }

  static Future<PostgrestList> getFirstLevelComments({
    required String blogId,
  }) async {
    try {
      final res = await supabase
          .from(Pages.comments.name)
          .select(
            "id, blog_id, user_id, comment, image_urls, created_at, updated_at, parent_id, user: profiles (id, display_name, image_url)",
          )
          .eq("blog_id", blogId)
          .isFilter("parent_id", null);

      return res;
    } catch (err) {
      debugPrint(err.toString());
      throw Exception('Fetching comments failed');
    }
  }

  static Future<PostgrestList> getCommentsUsingParentIds({
    required List<String> parentIds,
  }) async {
    try {
      final res = await supabase
          .from(Pages.comments.name)
          .select(
            "id, blog_id, user_id, comment, image_urls, created_at, updated_at, parent_id, user: profiles (id, display_name, image_url)",
          )
          .inFilter('parent_id', parentIds);

      return res;
    } catch (err) {
      debugPrint(err.toString());
      throw Exception('Fetching comments failed');
    }
  }

  static CommentModel buildNestedComments(
    PostgrestMap comment,
    PostgrestList comments,
  ) {
    // find all the comments that are having the current comment as parent_id
    final childrenComments = comments
        .where((c) => c['parent_id'] == comment['id'])
        .toList();

    // once it each the last child, convert it into comment model before returining
    if (childrenComments.isEmpty) {
      return CommentModel.fromJson(comment);
    }

    // keep converting each nested comments into CommentModel
    List<CommentModel> convertedChildrenComments = childrenComments.map((c) {
      return buildNestedComments(c, comments);
    }).toList();

    // convert the parent comment
    final updatedComment = CommentModel.fromJson(comment);

    // update the parent comment comments property
    return updatedComment.copyWith(comments: convertedChildrenComments);
  }

  static List<CommentModel> buildRootComments(
    PostgrestList rootComments,
    PostgrestList childrenComments,
  ) {
    return rootComments.map((e) {
      return buildNestedComments(e, childrenComments);
    }).toList();
  }
}
