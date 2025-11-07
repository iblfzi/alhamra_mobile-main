import 'package:flutter/material.dart';
import '../../../core/utils/app_styles.dart';

class CustomAvatarWidget extends StatelessWidget {
  final double radius;
  final String? imageUrl;
  final IconData? fallbackIcon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Widget? badge;
  final VoidCallback? onTap;

  const CustomAvatarWidget({
    super.key,
    this.radius = 20,
    this.imageUrl,
    this.fallbackIcon = Icons.person,
    this.backgroundColor,
    this.iconColor,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[300],
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null && fallbackIcon != null
          ? Icon(
              fallbackIcon,
              color: iconColor ?? Colors.grey,
              size: radius * 0.8,
            )
          : null,
    );

    if (badge != null) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            top: 0,
            child: badge!,
          ),
        ],
      );
    }

    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }
}

class IconAvatarWidget extends StatelessWidget {
  final IconData icon;
  final double radius;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const IconAvatarWidget({
    super.key,
    required this.icon,
    this.radius = 20,
    this.backgroundColor,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppStyles.primaryColor.withOpacity(0.1),
      child: Icon(
        icon,
        color: iconColor ?? AppStyles.primaryColor,
        size: radius * 0.8,
      ),
    );

    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }
}

class NotificationBadgeWidget extends StatelessWidget {
  final int count;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const NotificationBadgeWidget({
    super.key,
    required this.count,
    this.size = 16,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      child: Center(
        child: Text(
          count > 9 ? '9+' : count.toString(),
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: size * 0.6,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
