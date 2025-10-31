import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PaymentMethodCard extends StatelessWidget {
  final Map<String, dynamic> paymentMethod;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    Key? key,
    required this.paymentMethod,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return GestureDetector(
      onTap: onTap,
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
          boxShadow: isSelected
              ? AppTheme.getElevationShadow(isLight: isLight, elevation: 4.0)
              : AppTheme.getElevationShadow(isLight: isLight, elevation: 1.0),
        ),
        child: Row(
          children: [
            // Payment method icon/logo
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: Color(int.parse(paymentMethod['color'])),
                borderRadius: BorderRadius.circular(8),
              ),
              child: paymentMethod['logo'] != null
                  ? CustomImageWidget(
                      imageUrl: paymentMethod['logo'],
                      width: 12.w,
                      height: 12.w,
                      fit: BoxFit.contain,
                      semanticLabel: paymentMethod['logoDescription'] ??
                          'Payment method logo',
                    )
                  : CustomIconWidget(
                      iconName: paymentMethod['icon'],
                      color: Colors.white,
                      size: 6.w,
                    ),
            ),
            SizedBox(width: 4.w),

            // Payment method details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paymentMethod['name'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isLight
                              ? AppTheme.textPrimaryLight
                              : AppTheme.textPrimaryDark,
                        ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    paymentMethod['description'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isLight
                              ? AppTheme.textSecondaryLight
                              : AppTheme.textSecondaryDark,
                        ),
                  ),
                  if (paymentMethod['processingTime'] != null) ...[
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'access_time',
                          color: isLight
                              ? AppTheme.textSecondaryLight
                              : AppTheme.textSecondaryDark,
                          size: 3.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          paymentMethod['processingTime'],
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: isLight
                                        ? AppTheme.textSecondaryLight
                                        : AppTheme.textSecondaryDark,
                                  ),
                        ),
                      ],
                    ),
                  ],
                  if (paymentMethod['fee'] != null &&
                      paymentMethod['fee'] > 0) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      'Fee: ₱${paymentMethod['fee'].toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.warningLight,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
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
    );
  }
}
