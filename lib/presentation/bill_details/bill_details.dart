import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../core/app_export.dart';
import '../../services/backend_api_service.dart';
import '../../services/payment_api_service.dart';
import './widgets/bill_header_card.dart';
import './widgets/charges_breakdown.dart';
import './widgets/consumption_chart.dart';
import './widgets/meter_reading_section.dart';
import './widgets/payment_history_section.dart';

class BillDetails extends StatefulWidget {
  const BillDetails({Key? key}) : super(key: key);

  @override
  State<BillDetails> createState() => _BillDetailsState();
}

class _BillDetailsState extends State<BillDetails> {
  bool _isLoading = true;
  bool _isRefreshing = false;

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _billData;
  Map<String, dynamic>? _meterData;
  List<Map<String, dynamic>> _consumptionData = [];
  List<Map<String, dynamic>> _charges = [];
  List<Map<String, dynamic>> _paymentHistory = [];

  @override
  void initState() {
    super.initState();
    _loadBillData();
  }

  Future<void> _loadBillData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        _userData = json.decode(userDataString);
        final userId = int.parse(_userData!['id'].toString());

        // Load bill data
        final billResult = await BackendApiService.getLatestAmountDue(userId);
        if (billResult['success'] != false) {
          _billData = {
            "id": billResult['bill_id']?.toString() ?? 'N/A',
            "amount": billResult['amount_due'] ?? 0.0,
            "status": "pending", // Default status
            "dueDate": "TBD", // Not available in API
            "billingPeriod": "Current Period", // Not available
            "accountNumber": _userData!['meter_number'] ?? 'N/A',
            "customerName": _userData!['full_name'] ?? 'Unknown',
          };
        }

        // Load meter data
        final meterResult =
            await BackendApiService.getLatestMeterReading(userId);
        if (meterResult['success'] != false) {
          _meterData = {
            "currentReading":
                double.tryParse(meterResult['reading'].toString()) ?? 0.0,
            "previousReading": 0.0, // Not available
            "readingDate": DateTime.now().toString().split(' ')[0],
            "meterNumber": _userData!['meter_number'] ?? 'N/A',
            "photos": [], // Not available in API
          };
        }

        // Load payments if bill exists
        if (_billData != null && billResult['bill_id'] != null) {
          final paymentsResult = await PaymentApiService.getPaymentsByBillId(
              billResult['bill_id']);
          if (paymentsResult['success'] == true) {
            final payments = paymentsResult['data'] as List<dynamic>? ?? [];
            _paymentHistory = payments
                .map((p) => {
                      "id": p['id']?.toString() ?? 'N/A',
                      "amount":
                          double.tryParse(p['amount_paid'].toString()) ?? 0.0,
                      "method": p['payment_method'] ?? 'Unknown',
                      "status": 'completed',
                      "date": p['payment_date'] ??
                          DateTime.now().toString().split(' ')[0],
                      "referenceNumber": p['id']?.toString() ?? 'N/A',
                    })
                .toList();
          }
        }

        // Mock consumption data for now
        _consumptionData = [
          {"month": "May", "consumption": 22},
          {"month": "Jun", "consumption": 28},
          {"month": "Jul", "consumption": 35},
          {"month": "Aug", "consumption": 31},
          {"month": "Sep", "consumption": 26},
          {"month": "Oct", "consumption": 25},
        ];

        // Mock charges for now
        _charges = [
          {
            "name": "Water Bill",
            "description": "Current charges",
            "amount": _billData?['amount'] ?? 0.0,
            "fullDescription": "Outstanding water bill amount",
          },
        ];
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading bill data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Bill Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color:
                isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _shareBill,
            icon: CustomIconWidget(
              iconName: 'share',
              color:
                  isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              size: 24,
            ),
          ),
        ],
        elevation: 0,
        backgroundColor:
            isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      ),
      body: _isLoading
          ? _buildLoadingState(context, isDark)
          : _billData == null || _meterData == null
              ? _buildErrorState(context, isDark)
              : RefreshIndicator(
                  onRefresh: _refreshBillData,
                  color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  backgroundColor:
                      isDark ? AppTheme.cardDark : AppTheme.cardLight,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SafeArea(
                      child: Column(
                        children: [
                          BillHeaderCard(billData: _billData!),
                          MeterReadingSection(meterData: _meterData!),
                          ConsumptionChart(consumptionData: _consumptionData),
                          ChargesBreakdown(charges: _charges),
                          PaymentHistorySection(
                              paymentHistory: _paymentHistory),
                          SizedBox(height: 20.h), // Space for bottom buttons
                        ],
                      ),
                    ),
                  ),
                ),
      bottomNavigationBar: _buildBottomActions(context, isDark),
    );
  }

  Widget _buildLoadingState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
          ),
          SizedBox(height: 2.h),
          Text(
            'Loading bill details...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: isDark ? AppTheme.errorDark : AppTheme.errorLight,
          ),
          SizedBox(height: 2.h),
          Text(
            'Failed to load bill details',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: _loadBillData,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppTheme.shadowDark : AppTheme.shadowLight)
                .withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: _payNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  foregroundColor:
                      isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'payment',
                      color: isDark
                          ? AppTheme.onPrimaryDark
                          : AppTheme.onPrimaryLight,
                      size: 20,
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Pay Now - ₱${_billData!["amount"].toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isDark
                                ? AppTheme.onPrimaryDark
                                : AppTheme.onPrimaryLight,
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
              height: 5.h,
              child: OutlinedButton(
                onPressed: _downloadPDF,
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  side: BorderSide(
                    color:
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
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
                      iconName: 'download',
                      color:
                          isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                      size: 18,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Download PDF',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppTheme.primaryDark
                                : AppTheme.primaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshBillData() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bill information updated'),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.successDark
              : AppTheme.successLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _payNow() {
    HapticFeedback.selectionClick();
    Navigator.pushNamed(context, '/payment-methods');
  }

  void _downloadPDF() async {
    HapticFeedback.selectionClick();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.cardDark
                : AppTheme.cardLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.primaryDark
                    : AppTheme.primaryLight,
              ),
              SizedBox(height: 2.h),
              Text(
                'Generating PDF...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );

    // Simulate PDF generation
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bill PDF downloaded successfully'),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.successDark
              : AppTheme.successLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          action: SnackBarAction(
            label: 'Open',
            textColor: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.onPrimaryDark
                : AppTheme.onPrimaryLight,
            onPressed: () {
              // Handle PDF opening
            },
          ),
        ),
      );
    }
  }

  void _shareBill() {
    HapticFeedback.selectionClick();

    final billSummary = '''
Anopog - Water Bill Summary

Account: ${_billData!["accountNumber"]}
Customer: ${_billData!["customerName"]}
Billing Period: ${_billData!["billingPeriod"]}
Amount Due: ₱${_billData!["amount"].toStringAsFixed(2)}
Due Date: ${_billData!["dueDate"]}
Status: ${(_billData!["status"] as String).toUpperCase()}

Water Consumption: ${(_meterData!["currentReading"] as double).toInt()} m³

Download the Anopog app for easy bill payments and account management.
    ''';

    // In a real app, this would use the share plugin
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Bill details copied to clipboard'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.successDark
            : AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    Clipboard.setData(ClipboardData(text: billSummary));
  }
}
