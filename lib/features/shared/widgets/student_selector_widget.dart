import 'package:flutter/material.dart';
import '../../../core/utils/app_styles.dart';

class StudentSelectorWidget extends StatelessWidget {
  final String selectedStudent;
  final VoidCallback onTap;
  final String? avatarUrl;
  final String buttonText;
  final IconData buttonIcon;

  const StudentSelectorWidget({
    super.key,
    required this.selectedStudent,
    required this.onTap,
    this.avatarUrl,
    this.buttonText = 'Ganti',
    this.buttonIcon = Icons.swap_horiz,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppStyles.getCardBorderRadius(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null ? const Icon(Icons.person, color: Colors.grey) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedStudent,
                style: AppStyles.cardUsername(context),
              ),
            ),
            Text(
              buttonText,
              style: AppStyles.bodyText(context).copyWith(color: AppStyles.primaryColor),
            ),
            const SizedBox(width: 5),
            Icon(buttonIcon, color: AppStyles.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}
