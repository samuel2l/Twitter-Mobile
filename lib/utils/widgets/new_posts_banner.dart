import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class NewPostsBanner extends StatelessWidget {
  const NewPostsBanner({
    super.key,
    required this.count,
    required this.onTap,
    this.isLoading = false,
  });

  final int count;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final label = count == 1 ? 'See 1 new post' : 'See $count new posts';

    return Material(
      color: AppColors.primary,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}
