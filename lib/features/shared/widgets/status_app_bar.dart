import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:alhamra_1/core/utils/app_styles.dart';

class StatusAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final double height;
  final bool showBackButton;
  final List<Widget>? actions;

  const StatusAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.backgroundColor,
    this.height = 80.0,
    this.showBackButton = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: backgroundColor ?? AppStyles.primaryColor,
      child: SafeArea(
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Stack(
            children: [
              // Back button positioned on the left
              if (showBackButton)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: onBackPressed ?? () => Navigator.pop(context),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              // Centered title with better typography
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: showBackButton ? 56 : 16,
                  ),
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.15,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // Actions positioned on the right
              if (actions != null && actions!.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
