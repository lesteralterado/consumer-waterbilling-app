import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PaymentHistorySection extends StatelessWidget {
  final List<Map<String, dynamic>> paymentHistory;

  const PaymentHistorySection({
    Key? key,
    required this.paymentHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.getElevationShadow(isLight: !isDark, elevation: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Payments',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/payment-history'),
                child: Text(
                  'View All',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppTheme.primaryDark
                            : AppTheme.primaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          paymentHistory.isEmpty
              ? _buildEmptyState(context, isDark)
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      paymentHistory.length > 3 ? 3 : paymentHistory.length,
                  separatorBuilder: (context, index) => SizedBox(height: 2.h),
                  itemBuilder: (context, index) {
                    final payment = paymentHistory[index];
                    return _buildPaymentItem(context, payment, isDark);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(
      BuildContext context, Map<String, dynamic> payment, bool isDark) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
            .withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isDark ? AppTheme.dividerDark : AppTheme.dividerLight)
              .withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: _getPaymentStatusColor(payment["status"] as String, isDark)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: _getPaymentStatusIcon(payment["status"] as String),
                color:
                    _getPaymentStatusColor(payment["status"] as String, isDark),
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment["method"] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight,
                      ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  payment["date"] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₱${(payment["amount"] as double).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
              ),
              SizedBox(height: 0.5.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getPaymentStatusColor(
                          payment["status"] as String, isDark)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getPaymentStatusColor(
                        payment["status"] as String, isDark),
                    width: 1,
                  ),
                ),
                child: Text(
                  (payment["status"] as String).toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getPaymentStatusColor(
                            payment["status"] as String, isDark),
                        fontWeight: FontWeight.w600,
                        fontSize: 8.sp,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'payment',
            color:
                isDark ? AppTheme.textDisabledDark : AppTheme.textDisabledLight,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No payment history available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Your payment transactions will appear here',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppTheme.textDisabledDark
                      : AppTheme.textDisabledLight,
                ),
          ),
        ],
      ),
    );
  }

  Color _getPaymentStatusColor(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return isDark ? AppTheme.successDark : AppTheme.successLight;
      case 'pending':
      case 'processing':
        return isDark ? AppTheme.warningDark : AppTheme.warningLight;
      case 'failed':
      case 'cancelled':
        return isDark ? AppTheme.errorDark : AppTheme.errorLight;
      default:
        return isDark
            ? AppTheme.textSecondaryDark
            : AppTheme.textSecondaryLight;
    }
  }

  String _getPaymentStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return 'check_circle';
      case 'pending':
      case 'processing':
        return 'schedule';
      case 'failed':
      case 'cancelled':
        return 'error';
      default:
        return 'payment';
    }
  }
}
