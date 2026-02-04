import 'package:flutter/foundation.dart';
import 'package:flutter_blog_2/db.dart';
import 'package:flutter_blog_2/models/auth_model.dart';
import 'package:flutter_blog_2/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class AuthProvider extends ChangeNotifier {
  AuthModel state = AuthModel.initial();

  AuthModel get getState {
    return state;
  }

  AuthProvider() {
    if (state.user == null) {
      getUser();
    }
  }

  void _setState(AuthModel newState) {
    state = newState;
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    _setState(state.copyWith(loading: true));
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      _setState(state.copyWith(user: res.user));
    } catch (err) {
      debugPrint(err.toString());
      rethrow;
    } finally {
      _setState(state.copyWith(loading: false));
    }
  }

  Future<void> updateUser({required String name, File? image}) async {
    _setState(state.copyWith(loading: true));
    try {
      String? imageUrl; // add later.

      if (image != null) {
        imageUrl = await uploadImageToCloudinary(image);
      }

      final res = await supabase.auth.updateUser(
        UserAttributes(data: {'display_name': name, 'image_url': ?imageUrl}),
      );

      _setState(state.copyWith(user: res.user));
    } catch (err) {
      debugPrint(err.toString());
      rethrow;
    } finally {
      _setState(state.copyWith(loading: false));
    }
  }

  Future<void> getUser() async {
    _setState(state.copyWith(loading: true));
    try {
      final res = await supabase.auth.getUser();
      _setState(state.copyWith(user: res.user));
    } catch (err) {
      debugPrint(err.toString());
      throw Exception('Something went wrong');
    } finally {
      _setState(state.copyWith(loading: false));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setState(state.copyWith(loading: true));
    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
      );

      _setState(state.copyWith(user: res.user));
    } catch (err) {
      debugPrint(err.toString());
      rethrow;
    } finally {
      _setState(state.copyWith(loading: false));
    }
  }

  Future<void> logout() async {
    _setState(state.copyWith(loading: true));
    try {
      await supabase.auth.signOut();
      _setState(AuthModel.initial());
    } catch (err) {
      debugPrint(err.toString());
      // rethrow;
    } finally {
      _setState(state.copyWith(loading: false));
    }
  }
}
