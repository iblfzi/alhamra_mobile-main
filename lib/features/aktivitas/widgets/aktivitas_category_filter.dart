import 'package:flutter/material.dart';
import '../../../core/models/aktivitas_model.dart';
import '../../../core/utils/app_styles.dart';
import '../../../core/localization/app_localizations.dart';

/// Widget filter kategori aktivitas yang dapat dikonfigurasi.
class AktivitasCategoryFilter extends StatelessWidget {
  final ValueChanged<AktivitasType?> onCategorySelected;
  final TabController tabController;
  final List<AktivitasType?> categories;

  const AktivitasCategoryFilter({
    super.key,
    required this.onCategorySelected,
    required this.tabController,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        isScrollable: false,
        indicatorColor: AppStyles.primaryColor,
        indicatorWeight: 2,
        labelColor: AppStyles.primaryColor,
        unselectedLabelColor: Colors.grey[600],
        labelPadding: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        labelStyle: const TextStyle(
            fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w400),
        onTap: (index) {
          // Panggil callback onCategorySelected yang sudah ada di listener TabController
          // di halaman utama untuk menghindari panggilan ganda.
        },
        tabs: categories.map((category) {
          return Tab(text: _getLabelForCategory(category, context));
        }).toList(),
      ),
    );
  }

  /// Mendapatkan label dari enum atau mengembalikan "Semua" jika null.
  String _getLabelForCategory(AktivitasType? category, BuildContext context) {
    if (category == null) {
      return AppLocalizations.of(context).semua;
    }
    
    // Menggunakan translations untuk setiap kategori
    switch (category) {
      case AktivitasType.pelanggaran:
        return AppLocalizations.of(context).pelanggaran;
      case AktivitasType.perizinan:
        return AppLocalizations.of(context).perizinan;
      case AktivitasType.kesehatan:
        return AppLocalizations.of(context).kesehatan;
    }
  }
}
