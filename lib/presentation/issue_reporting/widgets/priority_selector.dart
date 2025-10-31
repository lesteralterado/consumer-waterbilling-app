import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PrioritySelector extends StatelessWidget {
  final String? selectedPriority;
  final Function(String) onPrioritySelected;

  const PrioritySelector({
    Key? key,
    required this.selectedPriority,
    required this.onPrioritySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final priorities = [
      {'name': 'Low', 'color': AppTheme.lightTheme.colorScheme.secondary},
      {'name': 'Medium', 'color': AppTheme.warningLight},
      {'name': 'High', 'color': AppTheme.lightTheme.colorScheme.error},
      {'name': 'Emergency', 'color': Color(0xFFD32F2F)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority Level *',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: priorities.map((priority) {
            final isSelected = selectedPriority == priority['name'];
            return Expanded(
              child: GestureDetector(
                onTap: () => onPrioritySelected(priority['name'] as String),
                child: Container(
                  margin: EdgeInsets.only(right: 2.w),
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (priority['color'] as Color).withValues(alpha: 0.1)
                        : AppTheme.lightTheme.colorScheme.surface,
                    border: Border.all(
                      color: isSelected
                          ? priority['color'] as Color
                          : AppTheme.lightTheme.colorScheme.outline,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    priority['name'] as String,
                    textAlign: TextAlign.center,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? priority['color'] as Color
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
