import 'package:flutter/foundation.dart';
import 'package:flutter_blog_2/models/comment_model.dart';

class CommentProvider extends ChangeNotifier {
  CommentModel state = CommentModel.initial();

  CommentModel get getState {
    return state;
  }

  void _setState(CommentModel newState) {
    state = newState;
    notifyListeners();
  }

  Future<void> getUser() async {
    // _setState(state.copyWith(loading: true));
    // try {
    //   final res = await supabase.Comment.getUser();
    //   _setState(state.copyWith(user: res.user));
    // } catch (err) {
    //   debugPrint(err.toString());
    //   throw Exception('Something went wrong');
    // } finally {
    //   _setState(state.copyWith(loading: false));
    // }
  }
}
