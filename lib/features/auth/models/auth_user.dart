class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.image,
  });

  final String id;
  final String name;
  final String email;
  final String? image;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      image: json['image'] as String?,
    );
  }
}
