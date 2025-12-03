import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/payment_api_service.dart';

class PaymongoPayment extends StatefulWidget {
  const PaymongoPayment({Key? key}) : super(key: key);

  @override
  State<PaymongoPayment> createState() => _PaymongoPaymentState();
}

class _PaymongoPaymentState extends State<PaymongoPayment> {
  bool _isLoading = false;
  String? _selectedPaymentType;

  // Payment data from arguments
  late String clientKey;
  late String paymentIntentId;
  late double amount;
  late String paymentMethod;
  late int billId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      clientKey = args['clientKey'];
      paymentIntentId = args['paymentIntentId'];
      amount = args['amount'];
      paymentMethod = args['paymentMethod'];
      billId = args['billId'];
    }
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Submit payment to backend (don't block on failure)
      final paymentDate = DateTime.now().toString().split(' ')[0];
      print('DEBUG: Submitting payment with:');
      print('  billId: $billId');
      print('  paymentDate: $paymentDate');
      print('  paymentMethod: $paymentMethod');
      print('  amountPaid: $amount');

      // Try to submit payment but don't fail the payment if backend fails
      Map<String, dynamic>? paymentResult;
      try {
        final result = await PaymentApiService.submitPayment(
          billId: billId,
          paymentDate: paymentDate,
          paymentMethod: paymentMethod,
          amountPaid: amount,
        );
        paymentResult = result;
        print('DEBUG: Payment submission result: $result');
      } catch (e) {
        print('DEBUG: Payment submission failed with exception: $e');
        paymentResult = {
          'success': false,
          'message': 'Backend submission failed'
        };
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Always navigate to confirmation since PayMongo payment "succeeded"
        Navigator.pushReplacementNamed(
          context,
          '/payment-confirmation',
          arguments: {
            'billId': billId,
            'paymentMethod': paymentMethod,
            'amountPaid': amount,
            'paymentDate': paymentDate,
            'paymentData': paymentResult?['data'] ??
                {'id': 'TXN-${DateTime.now().millisecondsSinceEpoch}'},
          },
        );

        // Show warning if backend submission failed
        if (paymentResult?['success'] != true) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Payment processed but record sync failed. Please contact support if needed.'),
                  backgroundColor: AppTheme.warningLight,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing payment: $e'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor:
          isLight ? AppTheme.backgroundLight : AppTheme.backgroundDark,
      appBar: AppBar(
        title: Text(
          'Complete Payment',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isLight
                    ? AppTheme.textPrimaryLight
                    : AppTheme.textPrimaryDark,
              ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color:
                isLight ? AppTheme.textPrimaryLight : AppTheme.textPrimaryDark,
            size: 6.w,
          ),
        ),
        backgroundColor: isLight
            ? AppTheme.lightTheme.colorScheme.surface
            : AppTheme.darkTheme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount display
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: isLight
                      ? AppTheme.lightTheme.colorScheme.surface
                      : AppTheme.darkTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isLight ? AppTheme.dividerLight : AppTheme.dividerDark,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isLight
                                ? AppTheme.textSecondaryLight
                                : AppTheme.textSecondaryDark,
                          ),
                    ),
                    Text(
                      '₱${amount.toStringAsFixed(2)}',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.lightTheme.primaryColor,
                              ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 4.h),

              // Payment method selection
              Text(
                'Select Payment Method',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isLight
                          ? AppTheme.textPrimaryLight
                          : AppTheme.textPrimaryDark,
                    ),
              ),

              SizedBox(height: 2.h),

              // GCash option
              _buildPaymentOption(
                'GCash',
                'gcash',
                'Pay with your GCash wallet',
                isLight,
              ),

              SizedBox(height: 2.h),

              // Card option
              _buildPaymentOption(
                'Credit/Debit Card',
                'card',
                'Visa, Mastercard, and other cards',
                isLight,
              ),

              SizedBox(height: 2.h),

              // PayMaya option
              _buildPaymentOption(
                'PayMaya',
                'paymaya',
                'Pay with your PayMaya wallet',
                isLight,
              ),

              Spacer(),

              // Pay button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: _selectedPaymentType != null && !_isLoading
                      ? _processPayment
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedPaymentType != null
                        ? AppTheme.lightTheme.primaryColor
                        : (isLight
                            ? AppTheme.dividerLight
                            : AppTheme.dividerDark),
                    foregroundColor: _selectedPaymentType != null
                        ? Colors.white
                        : (isLight
                            ? AppTheme.textDisabledLight
                            : AppTheme.textDisabledDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Pay ₱${amount.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
      String name, String type, String description, bool isLight) {
    final isSelected = _selectedPaymentType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isLight
              ? AppTheme.lightTheme.colorScheme.surface
              : AppTheme.darkTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.primaryColor
                : (isLight ? AppTheme.dividerLight : AppTheme.dividerDark),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: type,
              groupValue: _selectedPaymentType,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentType = value;
                });
              },
              activeColor: AppTheme.lightTheme.primaryColor,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isLight
                              ? AppTheme.textPrimaryLight
                              : AppTheme.textPrimaryDark,
                        ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isLight
                              ? AppTheme.textSecondaryLight
                              : AppTheme.textSecondaryDark,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
