import 'package:flutter/material.dart';

import '../../core/models/post_author.dart';
import '../theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.author,
    this.radius = 20,
  });

  final PostAuthor author;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final imageUrl = author.image;

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.surface,
      backgroundImage: imageUrl != null && imageUrl.isNotEmpty
          ? NetworkImage(imageUrl)
          : null,
      child: imageUrl == null || imageUrl.isEmpty
          ? Text(
              _initials(author.name),
              style: TextStyle(
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
