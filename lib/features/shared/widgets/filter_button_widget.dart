import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterButtonWidget extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasActiveFilters;

  const FilterButtonWidget({
    super.key,
    required this.onTap,
    required this.hasActiveFilters,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasActiveFilters ? Colors.blue[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasActiveFilters ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list,
              size: 16,
              color: hasActiveFilters ? Colors.blue : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              'Filter',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: hasActiveFilters ? Colors.blue : Colors.grey[600],
              ),
            ),
            if (hasActiveFilters) ...[
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
