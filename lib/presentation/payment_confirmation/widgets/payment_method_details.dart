import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PaymentMethodDetails extends StatelessWidget {
  final Map<String, dynamic> paymentMethodData;

  const PaymentMethodDetails({
    Key? key,
    required this.paymentMethodData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getPaymentMethodIcon(),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      paymentMethodData['methodName'] as String,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.successLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Verified',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.successLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildPaymentDetails(),
        ],
      ),
    );
  }

  Widget _getPaymentMethodIcon() {
    final methodType = paymentMethodData['type'] as String;

    switch (methodType.toLowerCase()) {
      case 'gcash':
        return Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: const Color(0xFF007DFE).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: 'account_balance_wallet',
            color: const Color(0xFF007DFE),
            size: 24,
          ),
        );
      case 'credit_card':
      case 'debit_card':
        return Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: 'credit_card',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
        );
      case 'bank_transfer':
        return Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: AppTheme.secondaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: 'account_balance',
            color: AppTheme.secondaryLight,
            size: 24,
          ),
        );
      default:
        return Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: AppTheme.textSecondaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: 'payment',
            color: AppTheme.textSecondaryLight,
            size: 24,
          ),
        );
    }
  }

  Widget _buildPaymentDetails() {
    final methodType = paymentMethodData['type'] as String;

    switch (methodType.toLowerCase()) {
      case 'gcash':
        return _buildGCashDetails();
      case 'credit_card':
      case 'debit_card':
        return _buildCardDetails();
      case 'bank_transfer':
        return _buildBankTransferDetails();
      default:
        return _buildGenericDetails();
    }
  }

  Widget _buildGCashDetails() {
    return Column(
      children: [
        _buildDetailRow(
          'Mobile Number',
          _maskMobileNumber(paymentMethodData['mobileNumber'] as String),
        ),
        SizedBox(height: 1.h),
        _buildDetailRow(
          'Transaction Reference',
          paymentMethodData['transactionReference'] as String,
        ),
        SizedBox(height: 1.h),
        _buildDetailRow(
          'Status',
          'Completed',
          valueColor: AppTheme.successLight,
        ),
      ],
    );
  }

  Widget _buildCardDetails() {
    return Column(
      children: [
        _buildDetailRow(
          'Card Number',
          '**** **** **** ${paymentMethodData['lastFourDigits'] as String}',
        ),
        SizedBox(height: 1.h),
        _buildDetailRow(
          'Card Type',
          paymentMethodData['cardBrand'] as String,
        ),
        SizedBox(height: 1.h),
        _buildDetailRow(
          'Authorization Code',
          paymentMethodData['authCode'] as String,
        ),
      ],
    );
  }

  Widget _buildBankTransferDetails() {
    return Column(
      children: [
        _buildDetailRow(
          'Bank Name',
          paymentMethodData['bankName'] as String,
        ),
        SizedBox(height: 1.h),
        _buildDetailRow(
          'Account Number',
          '**** **** ${paymentMethodData['lastFourDigits'] as String}',
        ),
        SizedBox(height: 1.h),
        _buildDetailRow(
          'Reference Number',
          paymentMethodData['referenceNumber'] as String,
        ),
      ],
    );
  }

  Widget _buildGenericDetails() {
    return _buildDetailRow(
      'Transaction ID',
      paymentMethodData['transactionId'] as String,
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryLight,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: valueColor ?? AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _maskMobileNumber(String mobileNumber) {
    if (mobileNumber.length < 4) return mobileNumber;
    final lastFour = mobileNumber.substring(mobileNumber.length - 4);
    return '+63 **** *** $lastFour';
  }
}
