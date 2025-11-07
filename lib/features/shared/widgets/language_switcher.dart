import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/language_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/app_styles.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool showLabel;
  final bool isCompact;
  
  const LanguageSwitcher({
    super.key,
    this.showLabel = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        final localizations = AppLocalizations.of(context);
        
        if (isCompact) {
          return _buildCompactSwitcher(context, languageService, localizations);
        }
        
        return _buildFullSwitcher(context, languageService, localizations);
      },
    );
  }
  
  Widget _buildCompactSwitcher(BuildContext context, LanguageService languageService, AppLocalizations localizations) {
    return GestureDetector(
      onTap: () => _showLanguageDialog(context, languageService, localizations),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppStyles.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppStyles.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language,
              size: 16,
              color: AppStyles.primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              languageService.currentLanguageCode,
              style: AppStyles.bodyText(context).copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppStyles.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFullSwitcher(BuildContext context, LanguageService languageService, AppLocalizations localizations) {
    return ListTile(
      leading: Icon(
        Icons.language,
        color: AppStyles.primaryColor,
      ),
      title: Text(
        localizations.bahasa,
        style: AppStyles.bodyText(context).copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        languageService.currentLanguageName,
        style: AppStyles.bodyText(context).copyWith(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showLanguageDialog(context, languageService, localizations),
    );
  }
  
  void _showLanguageDialog(BuildContext context, LanguageService languageService, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            localizations.pilihBahasa,
            style: AppStyles.heading2(context),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                context,
                languageService,
                'id',
                localizations.bahasaIndonesia,
                'Bahasa Indonesia',
                Icons.flag,
              ),
              const SizedBox(height: 8),
              _buildLanguageOption(
                context,
                languageService,
                'en',
                localizations.bahasaInggris,
                'English',
                Icons.flag_outlined,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                localizations.cancel,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildLanguageOption(
    BuildContext context,
    LanguageService languageService,
    String languageCode,
    String displayName,
    String nativeName,
    IconData icon,
  ) {
    final isSelected = languageService.currentLocale.languageCode == languageCode;
    
    return InkWell(
      onTap: () async {
        await languageService.changeLanguage(languageCode);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppStyles.primaryColor.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: AppStyles.primaryColor.withOpacity(0.3)) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppStyles.primaryColor : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: AppStyles.bodyText(context).copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppStyles.primaryColor : Colors.black87,
                    ),
                  ),
                  Text(
                    nativeName,
                    style: AppStyles.bodyText(context).copyWith(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppStyles.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
