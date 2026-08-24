class Topic {
  const Topic({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
  });

  final String id;
  final String name;
  final String slug;
  final String? description;

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
    );
  }
}

class OnboardingStatus {
  const OnboardingStatus({required this.completed});

  final bool completed;

  factory OnboardingStatus.fromJson(Map<String, dynamic> json) {
    return OnboardingStatus(completed: json['completed'] as bool? ?? false);
  }
}
