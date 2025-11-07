import 'package:flutter/material.dart';
import '../../../core/utils/app_styles.dart';

class CustomEmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  final double iconSize;
  final Color? iconColor;

  const CustomEmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.iconSize = 48,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor ?? Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppStyles.sectionTitle(context).copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppStyles.bodyText(context).copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}
