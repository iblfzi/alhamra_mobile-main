import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  const ProfileListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

