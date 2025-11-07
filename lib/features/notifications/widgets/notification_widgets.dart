import 'package:flutter/material.dart';

class BellIcon extends StatelessWidget {
  const BellIcon({super.key, this.color, this.size = 30});

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.notifications_none,
      color: color ?? Theme.of(context).iconTheme.color,
      size: size,
    );
  }
}

class RedDotBadge extends StatelessWidget {
  const RedDotBadge({
    super.key,
    this.size = 12,
    this.color = Colors.red,
    this.borderColor = Colors.white,
    this.borderWidth = 0,
    this.top = -2,
    this.right = -2,
    this.shadow,
  });

  final double size;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final double top;
  final double right;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: borderWidth > 0 ? Border.all(color: borderColor, width: borderWidth) : null,
          boxShadow: shadow,
        ),
      ),
    );
  }
}

