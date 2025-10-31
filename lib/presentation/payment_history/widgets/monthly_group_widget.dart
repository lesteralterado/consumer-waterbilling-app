import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './transaction_card_widget.dart';

class MonthlyGroupWidget extends StatefulWidget {
  final String monthYear;
  final List<Map<String, dynamic>> transactions;
  final Function(Map<String, dynamic>)? onTransactionTap;
  final Function(Map<String, dynamic>)? onViewReceipt;
  final Function(Map<String, dynamic>)? onDownloadPdf;
  final Function(Map<String, dynamic>)? onResendConfirmation;
  final bool initiallyExpanded;

  const MonthlyGroupWidget({
    Key? key,
    required this.monthYear,
    required this.transactions,
    this.onTransactionTap,
    this.onViewReceipt,
    this.onDownloadPdf,
    this.onResendConfirmation,
    this.initiallyExpanded = true,
  }) : super(key: key);

  @override
  State<MonthlyGroupWidget> createState() => _MonthlyGroupWidgetState();
}

class _MonthlyGroupWidgetState extends State<MonthlyGroupWidget>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  double _calculateTotalAmount() {
    return widget.transactions.fold(0.0, (sum, transaction) {
      return sum + (transaction['amount'] as double);
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _calculateTotalAmount();
    final transactionCount = widget.transactions.length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: _toggleExpansion,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.05),
                  borderRadius: _isExpanded
                      ? const BorderRadius.vertical(top: Radius.circular(12))
                      : BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.monthYear,
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              Text(
                                '$transactionCount transaction${transactionCount != 1 ? 's' : ''}',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '₱${totalAmount.toStringAsFixed(2)}',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: CustomIconWidget(
                        iconName: 'keyboard_arrow_down',
                        size: 24,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Column(
                children: widget.transactions.map((transaction) {
                  return TransactionCardWidget(
                    transaction: transaction,
                    onTap: () => widget.onTransactionTap?.call(transaction),
                    onViewReceipt: () =>
                        widget.onViewReceipt?.call(transaction),
                    onDownloadPdf: () =>
                        widget.onDownloadPdf?.call(transaction),
                    onResendConfirmation: () =>
                        widget.onResendConfirmation?.call(transaction),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
