import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SavedPaymentMethods extends StatelessWidget {
  final List<Map<String, dynamic>> savedMethods;
  final Function(String) onDeleteMethod;
  final Function(Map<String, dynamic>) onSelectMethod;
  final String? selectedMethodId;

  const SavedPaymentMethods({
    Key? key,
    required this.savedMethods,
    required this.onDeleteMethod,
    required this.onSelectMethod,
    this.selectedMethodId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    if (savedMethods.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Text(
            'Saved Payment Methods',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isLight
                      ? AppTheme.textPrimaryLight
                      : AppTheme.textPrimaryDark,
                ),
          ),
        ),
        ...savedMethods
            .map((method) => _buildSavedMethodCard(
                  context,
                  method,
                  isLight: isLight,
                ))
            .toList(),
      ],
    );
  }

  Widget _buildSavedMethodCard(
    BuildContext context,
    Map<String, dynamic> method, {
    required bool isLight,
  }) {
    final bool isSelected = selectedMethodId == method['id'];

    return Dismissible(
      key: Key(method['id']),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDeleteMethod(method['id']);
      },
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.errorLight,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'delete',
              color: Colors.white,
              size: 6.w,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Delete',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () => onSelectMethod(method),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
                : (isLight
                    ? AppTheme.lightTheme.colorScheme.surface
                    : AppTheme.darkTheme.colorScheme.surface),
            border: Border.all(
              color: isSelected
                  ? AppTheme.lightTheme.primaryColor
                  : (isLight ? AppTheme.dividerLight : AppTheme.dividerDark),
              width: isSelected ? 2.0 : 1.0,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                AppTheme.getElevationShadow(isLight: isLight, elevation: 1.0),
          ),
          child: Row(
            children: [
              // Card brand icon
              Container(
                width: 10.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: Color(int.parse(method['brandColor'])),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: CustomIconWidget(
                  iconName: method['brandIcon'],
                  color: Colors.white,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 4.w),

              // Card details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['cardBrand'],
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isLight
                                ? AppTheme.textPrimaryLight
                                : AppTheme.textPrimaryDark,
                          ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '**** **** **** ${method['lastFour']}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isLight
                                ? AppTheme.textSecondaryLight
                                : AppTheme.textSecondaryDark,
                            fontFamily: 'monospace',
                          ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Expires ${method['expiryMonth']}/${method['expiryYear']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isLight
                                ? AppTheme.textSecondaryLight
                                : AppTheme.textSecondaryDark,
                          ),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.lightTheme.primaryColor
                        : (isLight
                            ? AppTheme.dividerLight
                            : AppTheme.dividerDark),
                    width: 2.0,
                  ),
                  color: isSelected
                      ? AppTheme.lightTheme.primaryColor
                      : Colors.transparent,
                ),
                child: isSelected
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: Colors.white,
                        size: 3.w,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
