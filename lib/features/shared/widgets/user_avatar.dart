import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:alhamra_1/core/models/user_model.dart';
import 'package:alhamra_1/core/utils/app_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget untuk menampilkan avatar user dari Odoo atau default
class UserAvatar extends StatelessWidget {
  final UserModel? user;
  final double radius;
  final bool showEditButton;
  final VoidCallback? onEditTap;

  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 30,
    this.showEditButton = false,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    if (showEditButton) {
      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          _buildAvatar(),
          if (onEditTap != null)
            GestureDetector(
              onTap: onEditTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppStyles.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
        ],
      );
    }

    return _buildAvatar();
  }

  Widget _buildAvatar() {
    // Cek apakah ada avatar dari Odoo (base64)
    if (user?.avatar128 != null && user!.avatar128!.isNotEmpty) {
      try {
        
        Uint8List bytes = base64Decode(user!.avatar128!);

        final sampleLength = bytes.length > 256 ? 256 : bytes.length;
        final sampleText = utf8.decode(bytes.sublist(0, sampleLength), allowMalformed: true).toLowerCase();
        final isSvg = sampleText.contains('<svg');

        if (isSvg) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: AppStyles.primaryColor.withOpacity(0.1),
            child: ClipOval(
              child: SvgPicture.memory(
                bytes,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          return CircleAvatar(
            radius: radius,
            backgroundImage: MemoryImage(bytes),
            backgroundColor: AppStyles.primaryColor.withOpacity(0.1),
          );
        }
      } catch (e) {
        // Jika error, gunakan default avatar
        return _buildDefaultAvatar();
      }
    }

    // Default avatar dengan inisial atau icon
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    // Jika ada nama, tampilkan inisial
    if (user?.fullName != null && user!.fullName.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppStyles.primaryColor.withOpacity(0.1),
        child: Text(
          user!.fullName.substring(0, 2).toUpperCase(),
          style: TextStyle(
            color: AppStyles.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.6, 
          ),
        ),
      );
    }

    // Jika tidak ada nama, tampilkan icon
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppStyles.primaryColor.withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: radius * 1.2,
        color: AppStyles.primaryColor,
      ),
    );
  }
}
