class BlogUserModel {
  BlogUserModel({
    required this.id,
    required this.imageUrl,
    required this.displayName,
  });

  final String? id;
  final String? imageUrl;
  final String? displayName;

  factory BlogUserModel.initial() {
    return BlogUserModel(displayName: null, id: null, imageUrl: null);
  }

  BlogUserModel copyWith({String? id, String? imageUrl, String? displayName}) {
    return BlogUserModel(
      displayName: displayName ?? this.displayName,
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
