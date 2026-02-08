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

  factory BlogUserModel.formJson(Map<String, dynamic> json) {
    if (json case {
      'id': final String id,
      'image_url': final String imageUrl,
      'display_name': final String displayName,
    }) {
      return BlogUserModel(
        id: id,
        imageUrl: imageUrl,
        displayName: displayName,
      );
    } else {
      throw const FormatException(
        'Unexpected JSON format (BlogUserModel.formJson)',
      );
    }
  }

  BlogUserModel copyWith({String? id, String? imageUrl, String? displayName}) {
    return BlogUserModel(
      displayName: displayName ?? this.displayName,
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
