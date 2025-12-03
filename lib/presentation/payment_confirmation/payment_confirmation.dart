import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/bill_information_section.dart';
import './widgets/digital_receipt_section.dart';
import './widgets/next_bill_preview.dart';
import './widgets/payment_method_details.dart';
import './widgets/success_animation_widget.dart';
import './widgets/transaction_summary_card.dart';

class PaymentConfirmation extends StatefulWidget {
  const PaymentConfirmation({Key? key}) : super(key: key);

  @override
  State<PaymentConfirmation> createState() => _PaymentConfirmationState();
}

class _PaymentConfirmationState extends State<PaymentConfirmation> {
  bool _isLoading = false;

  late Map<String, dynamic> _transactionData;
  late Map<String, dynamic> _billData;
  late Map<String, dynamic> _paymentMethodData;
  late Map<String, dynamic> _nextBillData;
  late Map<String, dynamic> _receiptData;

  @override
  void initState() {
    super.initState();
    _initializeConfirmation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      // Extract real data from navigation arguments
      _transactionData = {
        'amount': args['amountPaid'] ?? 0.0,
        'paymentMethod': args['paymentMethod'] ?? 'Unknown',
        'transactionId': args['paymentData']?['id'] ??
            'TXN-${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': DateTime.now(),
        'reference': args['paymentData']?['reference'] ?? null,
        'status': 'completed',
      };

      _billData = {
        'accountNumber': 'WB-2024-${args['billId'] ?? '000000'}',
        'billingPeriod': DateTime.now().month == 1
            ? 'December ${DateTime.now().year - 1}'
            : '${_getMonthName(DateTime.now().month - 1)} ${DateTime.now().year}',
        'dueDate': DateTime.now().add(const Duration(days: 15)),
        'previousBalance': 0.0, // This would come from backend
        'currentCharges': args['amountPaid'] ?? 0.0,
        'totalAmount': args['amountPaid'] ?? 0.0,
      };

      _paymentMethodData = {
        'type': args['paymentMethod']?.toLowerCase() ?? 'unknown',
        'methodName': args['paymentMethod'] ?? 'Unknown Payment Method',
        'mobileNumber': '+639XXXXXXXXX', // This would come from user data
        'transactionReference': args['paymentData']?['reference'] ??
            'REF-${DateTime.now().millisecondsSinceEpoch}',
        'status': 'completed',
      };

      _nextBillData = {
        'currentBalance': 0.00,
        'nextDueDate': DateTime.now().add(const Duration(days: 30)),
        'nextBillDate': DateTime.now().add(const Duration(days: 15)),
        'estimatedAmount': 425.00, // This would come from backend
      };

      _receiptData = {
        'receiptNumber': 'RCP-${DateTime.now().millisecondsSinceEpoch}',
        'generatedAt': DateTime.now(),
        'format': 'PDF',
      };
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  void _initializeConfirmation() {
    // Trigger success notification via Semaphore.co API
    _sendPaymentConfirmationNotification();

    // Store receipt in payment history with PostgreSQL sync
    _syncPaymentHistory();
  }

  Future<void> _sendPaymentConfirmationNotification() async {
    try {
      // Simulate Semaphore.co API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock notification payload
      final notificationData = {
        'apikey': 'd403ca9a50e2a6840ccf3b0a5cbfe949',
        'number': '+639171234567',
        'message':
            'Anopog: Your water bill payment of ₱${_transactionData['amount'].toStringAsFixed(2)} has been successfully processed. Transaction ID: ${_transactionData['transactionId']}',
        'sendername': 'Anopog'
      };

      print('Notification sent: ${notificationData['message']}');
    } catch (e) {
      print('Failed to send notification: $e');
    }
  }

  Future<void> _syncPaymentHistory() async {
    try {
      // Simulate PostgreSQL sync
      await Future.delayed(const Duration(milliseconds: 500));

      final historyRecord = {
        'transaction_id': _transactionData['transactionId'],
        'account_number': _billData['accountNumber'],
        'amount': _transactionData['amount'],
        'payment_method': _transactionData['paymentMethod'],
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
        'receipt_data': _receiptData,
      };

      print('Payment history synced: ${historyRecord['transaction_id']}');
    } catch (e) {
      print('Failed to sync payment history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation to payment processing
        _returnToDashboard();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SuccessAnimationWidget(),
                      TransactionSummaryCard(transactionData: _transactionData),
                      BillInformationSection(billData: _billData),
                      PaymentMethodDetails(
                          paymentMethodData: _paymentMethodData),
                      DigitalReceiptSection(receiptData: _receiptData),
                      NextBillPreview(nextBillData: _nextBillData),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _returnToDashboard,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              'Payment Confirmation',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ),
          GestureDetector(
            onTap: _showHelpOptions,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: CustomIconWidget(
                iconName: 'help_outline',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _returnToDashboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
                elevation: 2,
                shadowColor: AppTheme.lightTheme.colorScheme.shadow,
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'home',
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Return to Dashboard',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: OutlinedButton(
              onPressed: _makeAnotherPayment,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                side: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'payment',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Make Another Payment',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _returnToDashboard() async {
    HapticFeedback.lightImpact();
    // ignore: avoid_print
    print(
        'DEBUG: Returning to dashboard from payment confirmation at ${DateTime.now()}');

    // Mark payment as successful to update bill state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_payment_amount', _transactionData['amount']);
    await prefs.setString(
        'last_payment_time', DateTime.now().toIso8601String());
    // ignore: avoid_print
    print('DEBUG: Set last_payment_amount to ${_transactionData['amount']}');

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
          (route) => false,
        );
      }
    });
  }

  void _makeAnotherPayment() {
    HapticFeedback.selectionClick();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Make Another Payment',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Would you like to make another payment for this account or a different account?',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/bill-details');
            },
            child: Text(
              'Same Account',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/dashboard');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Different Account',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpOptions() {
    HapticFeedback.selectionClick();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Need Help?',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            _buildHelpOption(
              'View Payment History',
              'history',
              () => Navigator.pushNamed(context, '/payment-history'),
            ),
            _buildHelpOption(
              'Contact Support',
              'support_agent',
              () => _contactSupport(),
            ),
            _buildHelpOption(
              'Report an Issue',
              'report_problem',
              () => Navigator.pushNamed(context, '/issue-reporting'),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpOption(String title, String icon, VoidCallback onTap) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: AppTheme.lightTheme.colorScheme.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        color: AppTheme.textSecondaryLight,
        size: 20,
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _contactSupport() {
    Fluttertoast.showToast(
      msg: "Opening support chat...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      textColor: Colors.white,
    );
  }
}
