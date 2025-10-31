import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TransactionSummaryCard extends StatelessWidget {
  final Map<String, dynamic> transactionData;

  const TransactionSummaryCard({
    Key? key,
    required this.transactionData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.getElevationShadow(isLight: true, elevation: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Summary',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 3.h),
          _buildSummaryRow(
            'Amount Paid',
            '₱${(transactionData['amount'] as double).toStringAsFixed(2)}',
            isAmount: true,
          ),
          SizedBox(height: 1.5.h),
          _buildSummaryRow(
            'Payment Method',
            transactionData['paymentMethod'] as String,
          ),
          SizedBox(height: 1.5.h),
          _buildSummaryRow(
            'Transaction ID',
            transactionData['transactionId'] as String,
          ),
          SizedBox(height: 1.5.h),
          _buildSummaryRow(
            'Date & Time',
            _formatDateTime(transactionData['timestamp'] as DateTime),
          ),
          if (transactionData['reference'] != null) ...[
            SizedBox(height: 1.5.h),
            _buildSummaryRow(
              'Reference Number',
              transactionData['reference'] as String,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isAmount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: isAmount
                ? AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.successLight,
                    fontWeight: FontWeight.w600,
                  )
                : AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute';
  }
}
