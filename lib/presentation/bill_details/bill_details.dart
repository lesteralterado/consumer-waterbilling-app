import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
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
  bool _isLoading = false;
  bool _isRefreshing = false;

  // Mock bill data
  final Map<String, dynamic> _billData = {
    "id": "BILL-2024-001",
    "amount": 1250.75,
    "status": "pending",
    "dueDate": "Nov 15, 2024",
    "billingPeriod": "Oct 1 - Oct 31, 2024",
    "accountNumber": "WTR-123456789",
    "customerName": "Maria Santos",
  };

  // Mock meter reading data
  final Map<String, dynamic> _meterData = {
    "currentReading": 1245,
    "previousReading": 1220,
    "readingDate": "Oct 31, 2024",
    "meterNumber": "MTR-789123",
    "photos": [
      {
        "url":
            "https://images.unsplash.com/photo-1558444686-de28038d378d",
        "semanticLabel":
            "Digital water meter display showing current reading of 1245 cubic meters with clear LCD screen and metal housing",
        "date": "Oct 31, 2024",
      },
      {
        "url":
            "https://images.unsplash.com/photo-1666855021109-c79420d7570a",
        "semanticLabel":
            "Close-up view of water meter installation with pipes and valve connections in outdoor utility box",
        "date": "Oct 31, 2024",
      },
    ],
  };

  // Mock consumption chart data
  final List<Map<String, dynamic>> _consumptionData = [
    {"month": "May", "consumption": 22},
    {"month": "Jun", "consumption": 28},
    {"month": "Jul", "consumption": 35},
    {"month": "Aug", "consumption": 31},
    {"month": "Sep", "consumption": 26},
    {"month": "Oct", "consumption": 25},
  ];

  // Mock charges breakdown
  final List<Map<String, dynamic>> _charges = [
    {
      "name": "Base Rate",
      "description": "Fixed monthly service charge",
      "amount": 150.00,
      "fullDescription":
          "This is the fixed monthly service charge that covers basic water infrastructure maintenance, meter reading services, and customer support operations.",
      "details": [
        {"item": "Service Connection", "amount": 100.00},
        {"item": "Meter Maintenance", "amount": 50.00},
      ],
    },
    {
      "name": "Water Consumption",
      "description": "25 m³ @ ₱18.50 per m³",
      "amount": 462.50,
      "fullDescription":
          "Water consumption charges are calculated based on your actual usage measured by the water meter. The current rate is ₱18.50 per cubic meter for residential customers.",
      "details": [
        {"item": "First 10 m³ @ ₱15.00", "amount": 150.00},
        {"item": "Next 15 m³ @ ₱20.83", "amount": 312.50},
      ],
    },
    {
      "name": "Environmental Fee",
      "description": "Water resource protection fee",
      "amount": 25.00,
      "fullDescription":
          "The environmental fee supports water resource protection programs, watershed management, and environmental compliance initiatives to ensure sustainable water supply.",
    },
    {
      "name": "VAT (12%)",
      "description": "Value Added Tax",
      "amount": 76.50,
      "fullDescription":
          "Value Added Tax is applied to water utility services as mandated by the Bureau of Internal Revenue. This tax supports government infrastructure and public services.",
    },
    {
      "name": "Sewerage Fee",
      "description": "Wastewater treatment charge",
      "amount": 536.75,
      "fullDescription":
          "Sewerage fees cover the cost of wastewater collection, treatment, and disposal services to protect public health and the environment.",
    },
  ];

  // Mock payment history
  final List<Map<String, dynamic>> _paymentHistory = [
    {
      "id": "PAY-2024-003",
      "amount": 1180.25,
      "method": "GCash",
      "status": "completed",
      "date": "Sep 12, 2024",
      "referenceNumber": "GC240912001",
    },
    {
      "id": "PAY-2024-002",
      "amount": 1095.50,
      "method": "Bank Transfer",
      "status": "completed",
      "date": "Aug 15, 2024",
      "referenceNumber": "BT240815002",
    },
    {
      "id": "PAY-2024-001",
      "amount": 1250.00,
      "method": "Over the Counter",
      "status": "completed",
      "date": "Jul 18, 2024",
      "referenceNumber": "OTC240718003",
    },
  ];

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
          : RefreshIndicator(
              onRefresh: _refreshBillData,
              color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              backgroundColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SafeArea(
                  child: Column(
                    children: [
                      BillHeaderCard(billData: _billData),
                      MeterReadingSection(meterData: _meterData),
                      ConsumptionChart(consumptionData: _consumptionData),
                      ChargesBreakdown(charges: _charges),
                      PaymentHistorySection(paymentHistory: _paymentHistory),
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
                    SizedBox(width: 2.w),
                    Text(
                      'Pay Now - ₱${_billData["amount"].toStringAsFixed(2)}',
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
AquaPay - Water Bill Summary

Account: ${_billData["accountNumber"]}
Customer: ${_billData["customerName"]}
Billing Period: ${_billData["billingPeriod"]}
Amount Due: ₱${_billData["amount"].toStringAsFixed(2)}
Due Date: ${_billData["dueDate"]}
Status: ${(_billData["status"] as String).toUpperCase()}

Water Consumption: ${(_meterData["currentReading"] as int) - (_meterData["previousReading"] as int)} m³

Download the AquaPay app for easy bill payments and account management.
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
