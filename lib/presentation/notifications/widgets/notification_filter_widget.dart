import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class NotificationFilterWidget extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final List<String> categories;

  const NotificationFilterWidget({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.categories,
  }) : super(key: key);

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'billing':
        return AppTheme.lightTheme.primaryColor;
      case 'service':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'maintenance':
        return const Color(0xFFFFC107);
      case 'emergency':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedFilter == category;

          return Container(
            margin: EdgeInsets.only(right: 2.w),
            child: FilterChip(
              label: Text(
                category == 'all' ? 'All' : category.toUpperCase(),
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : category == 'all'
                          ? AppTheme.lightTheme.colorScheme.onSurface
                          : _getCategoryColor(category),
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onFilterChanged(category);
                }
              },
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              selectedColor: category == 'all'
                  ? AppTheme.lightTheme.primaryColor
                  : _getCategoryColor(category),
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : category == 'all'
                        ? AppTheme.lightTheme.colorScheme.outline
                        : _getCategoryColor(category).withValues(alpha: 0.5),
                width: 1,
              ),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}
