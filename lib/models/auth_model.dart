import 'package:supabase_flutter/supabase_flutter.dart';

class AuthModel {
  final User? user;
  final Session? session;
  final bool loading;

  AuthModel({this.user, this.session, this.loading = false});

  factory AuthModel.initial() {
    return AuthModel(user: null, loading: false);
  }

  AuthModel copyWith({User? user, Session? session, bool? loading}) {
    return AuthModel(
      user: user ?? this.user,
      session: session ?? this.session,
      loading: loading ?? this.loading,
    );
  }
}
