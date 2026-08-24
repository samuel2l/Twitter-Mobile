class PostAuthor {
  const PostAuthor({
    required this.id,
    required this.name,
    this.image,
  });

  final String id;
  final String name;
  final String? image;

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      image: json['image'] as String?,
    );
  }
}
