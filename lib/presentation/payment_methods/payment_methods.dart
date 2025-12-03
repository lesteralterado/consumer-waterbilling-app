import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../services/payment_api_service.dart';
import '../../services/backend_api_service.dart';
import './widgets/amount_summary_card.dart';
import './widgets/payment_method_card.dart';
import './widgets/saved_payment_methods.dart';

class PaymentMethods extends StatefulWidget {
  const PaymentMethods({Key? key}) : super(key: key);

  @override
  State<PaymentMethods> createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods> {
  String? selectedPaymentMethodId;
  Map<String, dynamic>? selectedPaymentMethod;
  bool isLoading = false;

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _latestBill;
  bool billLoading = true;

  // Mock data for payment methods
  final List<Map<String, dynamic>> paymentMethods = [
    {
      'id': 'gcash',
      'name': 'GCash',
      'description': 'Pay instantly with your GCash wallet',
      'icon': 'account_balance_wallet',
      'logo': 'https://images.unsplash.com/photo-1695653422287-81cfeeb96ade',
      'logoDescription':
          'GCash mobile wallet logo with blue and white branding',
      'color': '0xFF007DFF',
      'fee': 0.0,
      'processingTime': 'Instant',
      'isAvailable': true,
      'type': 'digital_wallet',
    },
    {
      'id': 'credit_card',
      'name': 'Credit/Debit Card',
      'description': 'Visa, Mastercard, and other major cards',
      'icon': 'credit_card',
      'logo': null,
      'logoDescription': null,
      'color': '0xFF4CAF50',
      'fee': 15.0,
      'processingTime': '1-2 business days',
      'isAvailable': true,
      'type': 'card',
    },
    {
      'id': 'bank_transfer',
      'name': 'Bank Transfer',
      'description': 'Direct transfer from your bank account',
      'icon': 'account_balance',
      'logo': null,
      'logoDescription': null,
      'color': '0xFF2196F3',
      'fee': 10.0,
      'processingTime': '2-3 business days',
      'isAvailable': true,
      'type': 'bank_transfer',
    },
    {
      'id': 'over_counter',
      'name': 'Over-the-Counter',
      'description': 'Pay at 7-Eleven, SM, and other partner stores',
      'icon': 'store',
      'logo': null,
      'logoDescription': null,
      'color': '0xFFFF9800',
      'fee': 5.0,
      'processingTime': '1 business day',
      'isAvailable': true,
      'type': 'otc',
    },
    {
      'id': 'paymaya',
      'name': 'PayMaya',
      'description': 'Pay with your PayMaya digital wallet',
      'icon': 'payment',
      'logo': 'https://images.unsplash.com/photo-1677058054899-75c533d57048',
      'logoDescription':
          'PayMaya digital payment platform logo with green and white design',
      'color': '0xFF00C853',
      'fee': 0.0,
      'processingTime': 'Instant',
      'isAvailable': true,
      'type': 'digital_wallet',
    },
  ];

  // Mock data for saved payment methods
  final List<Map<String, dynamic>> savedPaymentMethods = [
    {
      'id': 'saved_visa_1',
      'cardBrand': 'Visa',
      'lastFour': '4532',
      'expiryMonth': '12',
      'expiryYear': '26',
      'brandIcon': 'credit_card',
      'brandColor': '0xFF1A1F71',
      'type': 'saved_card',
    },
    {
      'id': 'saved_mastercard_1',
      'cardBrand': 'Mastercard',
      'lastFour': '8901',
      'expiryMonth': '08',
      'expiryYear': '25',
      'brandIcon': 'credit_card',
      'brandColor': '0xFFEB001B',
      'type': 'saved_card',
    },
  ];

  // Bill data from backend
  int billId = 1;
  double billAmount = 0.0;
  double convenienceFee = 0.0;
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBillData();
  }

  Future<void> _loadBillData() async {
    setState(() {
      billLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        _userData = json.decode(userDataString);

        final userId = int.parse(_userData!['id'].toString());

        final billResult = await BackendApiService.getLatestAmountDue(userId);
        // ignore: avoid_print
        print('DEBUG: Backend bill API raw response => $billResult');
        if (billResult['success'] != false) {
          _latestBill = billResult;
        }
      }

      _updateBillData();
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: Error in _loadBillData => $e');
      _updateBillData();
    } finally {
      setState(() {
        billLoading = false;
      });
    }
  }

  void _updateBillData() {
    setState(() {
      if (_latestBill != null) {
        try {
          final amt = _latestBill!['amount_due'];
          if (amt == null) {
            billAmount = 0.0;
          } else if (amt is num) {
            billAmount = amt.toDouble();
          } else if (amt is String) {
            billAmount = double.tryParse(amt) ?? 0.0;
          } else {
            billAmount = 0.0;
          }

          final id = _latestBill!['id'];
          if (id != null) {
            billId = id is int ? id : int.tryParse(id.toString()) ?? 1;
          }
        } catch (e) {
          billAmount = 0.0;
          billId = 1;
        }
      } else {
        billAmount = 0.0;
        billId = 1;
      }

      _calculateTotalAmount();
    });
  }

  void _selectPaymentMethod(Map<String, dynamic> method) {
    setState(() {
      selectedPaymentMethodId = method['id'];
      selectedPaymentMethod = method;

      // Update convenience fee based on selected method
      if (method['type'] == 'saved_card') {
        convenienceFee = 15.0; // Standard card fee
      } else {
        convenienceFee = (method['fee'] as double?) ?? 0.0;
      }

      _calculateTotalAmount();
    });
  }

  void _calculateTotalAmount() {
    totalAmount = billAmount + convenienceFee;
  }

  void _deleteSavedMethod(String methodId) {
    setState(() {
      savedPaymentMethods.removeWhere((method) => method['id'] == methodId);

      // If the deleted method was selected, clear selection
      if (selectedPaymentMethodId == methodId) {
        selectedPaymentMethodId = null;
        selectedPaymentMethod = null;
        convenienceFee = 0.0;
        _calculateTotalAmount();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment method removed'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _addNewPaymentMethod() {
    // Navigate to add payment method screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add new payment method feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _proceedToPayment() async {
    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: AppTheme.errorLight,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Create PayMongo payment intent
      final paymentMethod = selectedPaymentMethod!['name'];
      final result = await PaymentApiService.createPaymentIntent(
        amount: totalAmount,
        currency: 'PHP',
        description: 'Water bill payment - $paymentMethod',
      );

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        if (result['success'] == true) {
          final paymentIntent = result['data'];
          // Debug logging
          print('DEBUG: paymentIntent => $paymentIntent');
          print('DEBUG: paymentIntent type => ${paymentIntent.runtimeType}');
          print('DEBUG: paymentIntent keys => ${paymentIntent?.keys.toList()}');

          if (paymentIntent == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment intent is null'),
                backgroundColor: AppTheme.errorLight,
                duration: Duration(seconds: 3),
              ),
            );
            return;
          }

          final clientKey = paymentIntent['client_key'];
          print('DEBUG: clientKey => $clientKey');

          final paymentIntentId = paymentIntent['id'];
          print('DEBUG: paymentIntentId => $paymentIntentId');

          // Debug logging
          print('DEBUG: Navigating to PayMongo with:');
          print('  clientKey: $clientKey');
          print('  paymentIntentId: $paymentIntentId');
          print('  amount: $totalAmount');
          print('  paymentMethod: $paymentMethod');
          print('  billId: $billId');

          // Navigate to PayMongo payment screen
          Navigator.pushNamed(
            context,
            '/paymongo-payment',
            arguments: {
              'clientKey': clientKey,
              'paymentIntentId':
                  paymentIntentId ?? '', // Provide empty string if null
              'amount': totalAmount,
              'paymentMethod': paymentMethod,
              'billId': billId,
            },
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(result['message'] ?? 'Failed to create payment intent'),
              backgroundColor: AppTheme.errorLight,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing payment: $e'),
            backgroundColor: AppTheme.errorLight,
            duration: Duration(seconds: 3),
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
          'Payment Methods',
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
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),

                    // Amount summary card
                    AmountSummaryCard(
                      billAmount: billAmount,
                      convenienceFee: convenienceFee,
                      totalAmount: totalAmount,
                    ),

                    SizedBox(height: 3.h),

                    // Saved payment methods section
                    // SavedPaymentMethods(
                    //   savedMethods: savedPaymentMethods,
                    //   onDeleteMethod: _deleteSavedMethod,
                    //   onSelectMethod: _selectPaymentMethod,
                    //   selectedMethodId: selectedPaymentMethodId,
                    // ),

                    // if (savedPaymentMethods.isNotEmpty) SizedBox(height: 2.h),

                    // Add new payment method button
                    // Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: 4.w),
                    //   child: OutlinedButton.icon(
                    //     onPressed: _addNewPaymentMethod,
                    //     icon: CustomIconWidget(
                    //       iconName: 'add',
                    //       color: AppTheme.lightTheme.primaryColor,
                    //       size: 5.w,
                    //     ),
                    //     label: Text(
                    //       'Add New Payment Method',
                    //       style:
                    //           Theme.of(context).textTheme.bodyMedium?.copyWith(
                    //                 color: AppTheme.lightTheme.primaryColor,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //     ),
                    //     style: OutlinedButton.styleFrom(
                    //       padding: EdgeInsets.symmetric(
                    //           horizontal: 4.w, vertical: 2.h),
                    //       side: BorderSide(
                    //         color: AppTheme.lightTheme.primaryColor,
                    //         width: 1.0,
                    //       ),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(12),
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    SizedBox(height: 3.h),

                    // Available payment methods section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        'Available Payment Methods',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isLight
                                      ? AppTheme.textPrimaryLight
                                      : AppTheme.textPrimaryDark,
                                ),
                      ),
                    ),

                    SizedBox(height: 1.h),

                    // Payment method cards
                    ...paymentMethods
                        .where((method) => method['isAvailable'] == true)
                        .take(1) // Only show the first payment method
                        .map(
                          (method) => PaymentMethodCard(
                            paymentMethod: method,
                            isSelected: selectedPaymentMethodId == method['id'],
                            onTap: () => _selectPaymentMethod(method),
                          ),
                        )
                        .toList(),

                    SizedBox(height: 12.h), // Space for fixed button
                  ],
                ),
              ),
            ),

            // Fixed continue button
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: isLight
                    ? AppTheme.lightTheme.colorScheme.surface
                    : AppTheme.darkTheme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color:
                        isLight ? AppTheme.dividerLight : AppTheme.dividerDark,
                    width: 1.0,
                  ),
                ),
                boxShadow: AppTheme.getElevationShadow(
                    isLight: isLight, elevation: 8.0),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedPaymentMethod != null && !isLoading
                      ? _proceedToPayment
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedPaymentMethod != null
                        ? AppTheme.lightTheme.primaryColor
                        : (isLight
                            ? AppTheme.dividerLight
                            : AppTheme.dividerDark),
                    foregroundColor: selectedPaymentMethod != null
                        ? Colors.white
                        : (isLight
                            ? AppTheme.textDisabledLight
                            : AppTheme.textDisabledDark),
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: selectedPaymentMethod != null ? 2.0 : 0.0,
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 6.w,
                          width: 6.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue to Payment',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: selectedPaymentMethod != null
                                        ? Colors.white
                                        : (isLight
                                            ? AppTheme.textDisabledLight
                                            : AppTheme.textDisabledDark),
                                  ),
                            ),
                            if (selectedPaymentMethod != null) ...[
                              SizedBox(width: 2.w),
                              CustomIconWidget(
                                iconName: 'arrow_forward',
                                color: Colors.white,
                                size: 5.w,
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
