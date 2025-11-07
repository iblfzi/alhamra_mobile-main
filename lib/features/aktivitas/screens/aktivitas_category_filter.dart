import 'package:flutter/material.dart';
import '../../../core/models/aktivitas_model.dart';
import '../../../core/utils/app_styles.dart';
import '../../../core/localization/app_localizations.dart';

class AktivitasCategoryFilter extends StatelessWidget {
  final AktivitasType? selectedCategory;
  final ValueChanged<AktivitasType?> onCategorySelected;

  const AktivitasCategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // Buat daftar semua opsi yang mungkin, termasuk 'Semua' (null)
    final List<AktivitasType?> categories = [null, ...AktivitasType.values];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: categories.map((category) {
          final isSelected = selectedCategory == category;
          final String label = _getLabelForCategory(context, category);

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onCategorySelected(category);
                }
              },
              selectedColor: AppStyles.primaryColor.withOpacity(0.15),
              labelStyle: TextStyle(
                color: isSelected ? AppStyles.primaryColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected ? AppStyles.primaryColor : Colors.grey.shade300,
              ),
              backgroundColor: Colors.white,
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getLabelForCategory(BuildContext context, AktivitasType? category) {
    final localizations = AppLocalizations.of(context);
    if (category == null) return localizations.semuaStatus;
    switch (category) {
      case AktivitasType.pelanggaran: return localizations.pelanggaran;
      case AktivitasType.perizinan: return localizations.perizinan;
      case AktivitasType.kesehatan: return localizations.kesehatan;
    }
  }
}