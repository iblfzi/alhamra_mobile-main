import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_styles.dart';

class CustomTabWidget extends StatelessWidget {
  final TabController tabController;
  final List<String> tabLabels;
  final VoidCallback? onTabChanged;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;

  const CustomTabWidget({
    super.key,
    required this.tabController,
    required this.tabLabels,
    this.onTabChanged,
    this.isScrollable = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.centerLeft,
      child: TabBar(
        controller: tabController,
        isScrollable: isScrollable,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        tabAlignment: TabAlignment.start,
        indicatorColor: AppStyles.primaryColor,
        indicatorWeight: 3,
        labelColor: AppStyles.primaryColor,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: (index) => onTabChanged?.call(),
        tabs: tabLabels.map((label) => Tab(text: label)).toList(),
      ),
    );
  }
}

class CustomFilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? selectedColor;
  final Color? unselectedColor;

  const CustomFilterChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final chipStyle = AppStyles.bodyText(context).copyWith(fontSize: 11);
    
    return ChoiceChip(
      label: Text(label, style: chipStyle),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: (selectedColor ?? AppStyles.primaryColor).withOpacity(0.15),
      side: BorderSide(
        color: isSelected 
            ? (selectedColor ?? AppStyles.primaryColor)
            : Colors.grey.shade300,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      labelStyle: chipStyle.copyWith(
        color: isSelected 
            ? (selectedColor ?? AppStyles.primaryColor)
            : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      avatar: icon != null ? Icon(icon, size: 14) : null,
    );
  }
}

class PeriodFilterWidget extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;
  final List<String> periods;

  const PeriodFilterWidget({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.periods = const ['Bulan Ini', 'Bulan Lalu', '3 Bulan'],
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: periods.map((period) {
        return CustomFilterChipWidget(
          label: period,
          isSelected: selectedPeriod == period,
          onTap: () => onPeriodChanged(period),
        );
      }).toList(),
    );
  }
}
