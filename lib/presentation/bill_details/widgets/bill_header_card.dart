import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class BillHeaderCard extends StatelessWidget {
  final Map<String, dynamic> billData;

  const BillHeaderCard({
    Key? key,
    required this.billData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.getElevationShadow(isLight: !isDark, elevation: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Bill',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '₱${(billData["amount"] as double).toStringAsFixed(2)}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppTheme.primaryDark
                                    : AppTheme.primaryLight,
                              ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(billData["status"] as String, isDark)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        _getStatusColor(billData["status"] as String, isDark),
                    width: 1,
                  ),
                ),
                child: Text(
                  (billData["status"] as String).toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getStatusColor(
                            billData["status"] as String, isDark),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  context,
                  'Due Date',
                  billData["dueDate"] as String,
                  isDark,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildInfoItem(
                  context,
                  'Billing Period',
                  billData["billingPeriod"] as String,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      BuildContext context, String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'paid':
        return isDark ? AppTheme.successDark : AppTheme.successLight;
      case 'pending':
        return isDark ? AppTheme.warningDark : AppTheme.warningLight;
      case 'overdue':
        return isDark ? AppTheme.errorDark : AppTheme.errorLight;
      default:
        return isDark
            ? AppTheme.textSecondaryDark
            : AppTheme.textSecondaryLight;
    }
  }
}
