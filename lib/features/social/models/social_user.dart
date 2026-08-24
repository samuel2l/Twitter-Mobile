class SocialUser {
  const SocialUser({
    required this.id,
    required this.name,
    this.image,
    this.followedAt,
  });

  final String id;
  final String name;
  final String? image;
  final DateTime? followedAt;

  factory SocialUser.fromJson(Map<String, dynamic> json) {
    return SocialUser(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      image: json['image'] as String?,
      followedAt: json['followedAt'] != null
          ? DateTime.tryParse(json['followedAt'] as String)
          : null,
    );
  }
}
