import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.backgroundColor,
    this.centerTitle = true,
  });

  final String title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: actions,
    );
  }
}

