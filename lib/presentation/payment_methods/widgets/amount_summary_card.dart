import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AmountSummaryCard extends StatelessWidget {
  final double billAmount;
  final double convenienceFee;
  final double totalAmount;

  const AmountSummaryCard({
    Key? key,
    required this.billAmount,
    required this.convenienceFee,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isLight
            ? AppTheme.lightTheme.colorScheme.surface
            : AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLight ? AppTheme.dividerLight : AppTheme.dividerDark,
          width: 1.0,
        ),
        boxShadow:
            AppTheme.getElevationShadow(isLight: isLight, elevation: 2.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isLight
                      ? AppTheme.textPrimaryLight
                      : AppTheme.textPrimaryDark,
                ),
          ),
          SizedBox(height: 2.h),

          // Bill amount row
          _buildAmountRow(
            context,
            'Bill Amount',
            billAmount,
            isLight: isLight,
          ),
          SizedBox(height: 1.h),

          // Convenience fee row
          _buildAmountRow(
            context,
            'Convenience Fee',
            convenienceFee,
            isLight: isLight,
            isWarning: convenienceFee > 0,
          ),

          // Divider
          Container(
            margin: EdgeInsets.symmetric(vertical: 1.5.h),
            height: 1,
            color: isLight ? AppTheme.dividerLight : AppTheme.dividerDark,
          ),

          // Total amount row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isLight
                          ? AppTheme.textPrimaryLight
                          : AppTheme.textPrimaryDark,
                    ),
              ),
              Text(
                '₱${totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.lightTheme.primaryColor,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    BuildContext context,
    String label,
    double amount, {
    required bool isLight,
    bool isWarning = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isLight
                    ? AppTheme.textSecondaryLight
                    : AppTheme.textSecondaryDark,
              ),
        ),
        Text(
          amount > 0 ? '₱${amount.toStringAsFixed(2)}' : 'FREE',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isWarning
                    ? AppTheme.warningLight
                    : (isLight
                        ? AppTheme.textPrimaryLight
                        : AppTheme.textPrimaryDark),
              ),
        ),
      ],
    );
  }
}
