import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/monthly_group_widget.dart';
import './widgets/search_bar_widget.dart';

class PaymentHistory extends StatefulWidget {
  const PaymentHistory({Key? key}) : super(key: key);

  @override
  State<PaymentHistory> createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _allTransactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  Map<String, List<Map<String, dynamic>>> _groupedTransactions = {};
  Map<String, dynamic> _activeFilters = {};
  List<String> _activeFilterChips = [];
  bool _isLoading = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadTransactions() {
    setState(() {
      _isLoading = true;
    });

    // Mock transaction data
    _allTransactions = [
      {
        "transactionId": "TXN202410280001",
        "amount": 1250.50,
        "date": DateTime(2024, 10, 25, 14, 30),
        "status": "successful",
        "method": "GCash",
        "billPeriod": "September 2024",
        "receiptUrl": "https://example.com/receipt1.pdf",
        "description": "Water Bill Payment - September 2024",
        "processingFee": 15.00,
        "referenceNumber": "GC240925001"
      },
      {
        "transactionId": "TXN202410270002",
        "amount": 980.75,
        "date": DateTime(2024, 10, 22, 9, 15),
        "status": "pending",
        "method": "Credit Card",
        "billPeriod": "August 2024",
        "receiptUrl": "https://example.com/receipt2.pdf",
        "description": "Water Bill Payment - August 2024",
        "processingFee": 25.00,
        "referenceNumber": "CC240822002"
      },
      {
        "transactionId": "TXN202410260003",
        "amount": 1450.25,
        "date": DateTime(2024, 10, 20, 16, 45),
        "status": "failed",
        "method": "Bank Transfer",
        "billPeriod": "July 2024",
        "receiptUrl": null,
        "description": "Water Bill Payment - July 2024",
        "processingFee": 0.00,
        "referenceNumber": "BT240720003",
        "failureReason": "Insufficient funds"
      },
      {
        "transactionId": "TXN202409250004",
        "amount": 1125.00,
        "date": DateTime(2024, 9, 25, 11, 20),
        "status": "successful",
        "method": "GCash",
        "billPeriod": "June 2024",
        "receiptUrl": "https://example.com/receipt4.pdf",
        "description": "Water Bill Payment - June 2024",
        "processingFee": 15.00,
        "referenceNumber": "GC240625004"
      },
      {
        "transactionId": "TXN202409220005",
        "amount": 875.50,
        "date": DateTime(2024, 9, 22, 13, 10),
        "status": "successful",
        "method": "Cash",
        "billPeriod": "May 2024",
        "receiptUrl": "https://example.com/receipt5.pdf",
        "description": "Water Bill Payment - May 2024",
        "processingFee": 0.00,
        "referenceNumber": "CASH240522005"
      },
      {
        "transactionId": "TXN202408280006",
        "amount": 1350.75,
        "date": DateTime(2024, 8, 28, 10, 30),
        "status": "successful",
        "method": "Credit Card",
        "billPeriod": "April 2024",
        "receiptUrl": "https://example.com/receipt6.pdf",
        "description": "Water Bill Payment - April 2024",
        "processingFee": 25.00,
        "referenceNumber": "CC240428006"
      },
      {
        "transactionId": "TXN202408250007",
        "amount": 1200.00,
        "date": DateTime(2024, 8, 25, 15, 45),
        "status": "pending",
        "method": "Bank Transfer",
        "billPeriod": "March 2024",
        "receiptUrl": null,
        "description": "Water Bill Payment - March 2024",
        "processingFee": 20.00,
        "referenceNumber": "BT240325007"
      },
      {
        "transactionId": "TXN202407280008",
        "amount": 950.25,
        "date": DateTime(2024, 7, 28, 12, 15),
        "status": "successful",
        "method": "GCash",
        "billPeriod": "February 2024",
        "receiptUrl": "https://example.com/receipt8.pdf",
        "description": "Water Bill Payment - February 2024",
        "processingFee": 15.00,
        "referenceNumber": "GC240228008"
      },
    ];

    _applyFiltersAndSearch();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshTransactions() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    _loadTransactions();

    setState(() {
      _isRefreshing = false;
    });
  }

  void _onSearchChanged() {
    _applyFiltersAndSearch();
  }

  void _applyFiltersAndSearch() {
    List<Map<String, dynamic>> filtered = List.from(_allTransactions);

    // Apply search filter
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        final transactionId =
            (transaction['transactionId'] as String).toLowerCase();
        final amount = transaction['amount'].toString();
        final method = (transaction['method'] as String).toLowerCase();
        final billPeriod = (transaction['billPeriod'] as String).toLowerCase();

        return transactionId.contains(searchQuery) ||
            amount.contains(searchQuery) ||
            method.contains(searchQuery) ||
            billPeriod.contains(searchQuery);
      }).toList();
    }

    // Apply status filter
    if (_activeFilters['status'] != null && _activeFilters['status'] != 'All') {
      filtered = filtered.where((transaction) {
        return (transaction['status'] as String).toLowerCase() ==
            (_activeFilters['status'] as String).toLowerCase();
      }).toList();
    }

    // Apply payment method filter
    if (_activeFilters['paymentMethod'] != null &&
        _activeFilters['paymentMethod'] != 'All') {
      filtered = filtered.where((transaction) {
        return (transaction['method'] as String).toLowerCase() ==
            (_activeFilters['paymentMethod'] as String).toLowerCase();
      }).toList();
    }

    // Apply amount range filter
    if (_activeFilters['amountRange'] != null &&
        _activeFilters['amountRange'] != 'All') {
      filtered = filtered.where((transaction) {
        final amount = transaction['amount'] as double;
        final range = _activeFilters['amountRange'] as String;

        switch (range) {
          case '₱0 - ₱500':
            return amount <= 500;
          case '₱501 - ₱1,000':
            return amount > 500 && amount <= 1000;
          case '₱1,001 - ₱2,000':
            return amount > 1000 && amount <= 2000;
          case '₱2,000+':
            return amount > 2000;
          default:
            return true;
        }
      }).toList();
    }

    // Apply date range filter
    if (_activeFilters['dateRange'] != null) {
      final dateRange = _activeFilters['dateRange'] as DateTimeRange;
      filtered = filtered.where((transaction) {
        final transactionDate = transaction['date'] as DateTime;
        return transactionDate
                .isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
            transactionDate
                .isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Sort by date (newest first)
    filtered.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    setState(() {
      _filteredTransactions = filtered;
      _groupTransactionsByMonth();
      _updateActiveFilterChips();
    });
  }

  void _groupTransactionsByMonth() {
    _groupedTransactions.clear();

    for (final transaction in _filteredTransactions) {
      final date = transaction['date'] as DateTime;
      final monthYear = '${_getMonthName(date.month)} ${date.year}';

      if (_groupedTransactions[monthYear] == null) {
        _groupedTransactions[monthYear] = [];
      }
      _groupedTransactions[monthYear]!.add(transaction);
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

  void _updateActiveFilterChips() {
    _activeFilterChips.clear();

    if (_activeFilters['status'] != null && _activeFilters['status'] != 'All') {
      _activeFilterChips.add('Status: ${_activeFilters['status']}');
    }

    if (_activeFilters['paymentMethod'] != null &&
        _activeFilters['paymentMethod'] != 'All') {
      _activeFilterChips.add('Method: ${_activeFilters['paymentMethod']}');
    }

    if (_activeFilters['amountRange'] != null &&
        _activeFilters['amountRange'] != 'All') {
      _activeFilterChips.add('Amount: ${_activeFilters['amountRange']}');
    }

    if (_activeFilters['dateRange'] != null) {
      final dateRange = _activeFilters['dateRange'] as DateTimeRange;
      _activeFilterChips.add(
          'Date: ${dateRange.start.day}/${dateRange.start.month} - ${dateRange.end.day}/${dateRange.end.month}');
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 80.h,
        child: FilterBottomSheetWidget(
          currentFilters: _activeFilters,
          onApplyFilters: (filters) {
            setState(() {
              _activeFilters = filters;
            });
            _applyFiltersAndSearch();
          },
        ),
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters.clear();
      _activeFilterChips.clear();
    });
    _applyFiltersAndSearch();
  }

  void _removeFilter(String filterChip) {
    if (filterChip.startsWith('Status:')) {
      _activeFilters.remove('status');
    } else if (filterChip.startsWith('Method:')) {
      _activeFilters.remove('paymentMethod');
    } else if (filterChip.startsWith('Amount:')) {
      _activeFilters.remove('amountRange');
    } else if (filterChip.startsWith('Date:')) {
      _activeFilters.remove('dateRange');
    }
    _applyFiltersAndSearch();
  }

  void _onTransactionTap(Map<String, dynamic> transaction) {
    _showTransactionDetails(transaction);
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 70.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.05),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 12.w,
                    height: 0.5.h,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Transaction Details',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                        'Transaction ID', transaction['transactionId']),
                    _buildDetailRow('Amount',
                        '₱${(transaction['amount'] as double).toStringAsFixed(2)}'),
                    _buildDetailRow('Date',
                        '${(transaction['date'] as DateTime).day}/${(transaction['date'] as DateTime).month}/${(transaction['date'] as DateTime).year} ${(transaction['date'] as DateTime).hour.toString().padLeft(2, '0')}:${(transaction['date'] as DateTime).minute.toString().padLeft(2, '0')}'),
                    _buildDetailRow('Status', transaction['status']),
                    _buildDetailRow('Payment Method', transaction['method']),
                    _buildDetailRow('Bill Period', transaction['billPeriod']),
                    _buildDetailRow(
                        'Reference Number', transaction['referenceNumber']),
                    _buildDetailRow('Processing Fee',
                        '₱${(transaction['processingFee'] as double).toStringAsFixed(2)}'),
                    if (transaction['failureReason'] != null)
                      _buildDetailRow(
                          'Failure Reason', transaction['failureReason']),
                    SizedBox(height: 3.h),
                    if (transaction['receiptUrl'] != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _viewReceipt(transaction),
                          icon: CustomIconWidget(
                            iconName: 'receipt',
                            size: 20,
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                          ),
                          label: const Text('View Receipt'),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _downloadReceipt(transaction),
                          icon: CustomIconWidget(
                            iconName: 'download',
                            size: 20,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                          label: const Text('Download PDF'),
                        ),
                      ),
                    ],
                    if (transaction['status'] == 'failed') ...[
                      SizedBox(height: 2.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _retryPayment(transaction),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.warningLight,
                          ),
                          icon: CustomIconWidget(
                            iconName: 'refresh',
                            size: 20,
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                          ),
                          label: const Text('Retry Payment'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 35.w,
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewReceipt(Map<String, dynamic> transaction) {
    Navigator.pop(context);
    // In a real app, this would open a PDF viewer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Opening receipt for transaction ${transaction['transactionId']}'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  Future<void> _downloadReceipt(Map<String, dynamic> transaction) async {
    Navigator.pop(context);

    try {
      final receiptContent = _generateReceiptContent(transaction);
      final filename = 'receipt_${transaction['transactionId']}.txt';

      if (kIsWeb) {
        final bytes = utf8.encode(receiptContent);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsString(receiptContent);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Receipt downloaded successfully'),
          backgroundColor: AppTheme.successLight,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download receipt'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  String _generateReceiptContent(Map<String, dynamic> transaction) {
    return '''
AquaPay - Payment Receipt
========================

Transaction ID: ${transaction['transactionId']}
Date: ${(transaction['date'] as DateTime).day}/${(transaction['date'] as DateTime).month}/${(transaction['date'] as DateTime).year}
Time: ${(transaction['date'] as DateTime).hour.toString().padLeft(2, '0')}:${(transaction['date'] as DateTime).minute.toString().padLeft(2, '0')}

Bill Details:
- Bill Period: ${transaction['billPeriod']}
- Amount: ₱${(transaction['amount'] as double).toStringAsFixed(2)}
- Processing Fee: ₱${(transaction['processingFee'] as double).toStringAsFixed(2)}
- Total: ₱${((transaction['amount'] as double) + (transaction['processingFee'] as double)).toStringAsFixed(2)}

Payment Details:
- Method: ${transaction['method']}
- Reference: ${transaction['referenceNumber']}
- Status: ${transaction['status']}

Thank you for using AquaPay!
''';
  }

  void _retryPayment(Map<String, dynamic> transaction) {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/payment-methods');
  }

  void _resendConfirmation(Map<String, dynamic> transaction) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Confirmation resent for transaction ${transaction['transactionId']}'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  Future<void> _exportTransactions() async {
    try {
      final csvContent = _generateCsvContent();
      final filename =
          'payment_history_${DateTime.now().millisecondsSinceEpoch}.csv';

      if (kIsWeb) {
        final bytes = utf8.encode(csvContent);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsString(csvContent);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment history exported successfully'),
          backgroundColor: AppTheme.successLight,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export payment history'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  String _generateCsvContent() {
    final buffer = StringBuffer();
    buffer.writeln(
        'Transaction ID,Date,Amount,Status,Payment Method,Bill Period,Reference Number');

    for (final transaction in _filteredTransactions) {
      final date = transaction['date'] as DateTime;
      buffer.writeln('${transaction['transactionId']},'
          '${date.day}/${date.month}/${date.year},'
          '${transaction['amount']},'
          '${transaction['status']},'
          '${transaction['method']},'
          '${transaction['billPeriod']},'
          '${transaction['referenceNumber']}');
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Payment History',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        actions: [
          IconButton(
            onPressed: _exportTransactions,
            icon: CustomIconWidget(
              iconName: 'file_download',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            tooltip: 'Export CSV',
          ),
        ],
      ),
      body: Column(
        children: [
          SearchBarWidget(
            controller: _searchController,
            hintText: 'Search by ID, amount, method...',
            onFilterTap: _showFilterBottomSheet,
          ),
          FilterChipsWidget(
            activeFilters: _activeFilterChips,
            onClearAll: _clearAllFilters,
            onRemoveFilter: _removeFilter,
          ),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _filteredTransactions.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _refreshTransactions,
                        color: AppTheme.lightTheme.colorScheme.primary,
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _groupedTransactions.keys.length,
                          itemBuilder: (context, index) {
                            final monthYear =
                                _groupedTransactions.keys.elementAt(index);
                            final transactions =
                                _groupedTransactions[monthYear]!;

                            return MonthlyGroupWidget(
                              monthYear: monthYear,
                              transactions: transactions,
                              initiallyExpanded: index == 0,
                              onTransactionTap: _onTransactionTap,
                              onViewReceipt: _viewReceipt,
                              onDownloadPdf: _downloadReceipt,
                              onResendConfirmation: _resendConfirmation,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Loading payment history...',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'receipt_long',
              size: 64,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.5),
            ),
            SizedBox(height: 3.h),
            Text(
              'No transactions found',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _searchController.text.isNotEmpty || _activeFilters.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'Your payment history will appear here',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchController.text.isNotEmpty ||
                _activeFilters.isNotEmpty) ...[
              SizedBox(height: 3.h),
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  _clearAllFilters();
                },
                child: const Text('Clear All Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
