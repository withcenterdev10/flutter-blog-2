class BlogModel {
  BlogModel({
    required this.title,
    required this.blog,
    required this.userId,
    this.loading = false,
  });

  final String? title;
  final String? blog;
  final String? userId;
  final bool loading;

  factory BlogModel.initial() {
    return BlogModel(title: null, blog: null, userId: null, loading: false);
  }

  BlogModel copyWith({
    String? title,
    String? blog,
    String? userId,
    bool? loading,
  }) {
    return BlogModel(
      title: title ?? this.title,
      blog: blog ?? this.blog,
      userId: userId ?? this.userId,
      loading: loading ?? this.loading,
    );
  }
}
