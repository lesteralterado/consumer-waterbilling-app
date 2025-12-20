import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../services/backend_api_service.dart';

class AccountStatusCard extends StatefulWidget {
  final String customerName;
  final String accountNumber;
  final String status;
  final double? currentBill; // optional - if null, will be fetched
  final DateTime? dueDate; // optional
  final String? meterReading; // optional - if null, will be fetched
  final int? userId; // optional: user id used to fetch remote data

  const AccountStatusCard({
    Key? key,
    required this.customerName,
    required this.accountNumber,
    required this.status,
    this.currentBill,
    this.dueDate,
    this.meterReading,
    this.userId,
  }) : super(key: key);

  @override
  State<AccountStatusCard> createState() => _AccountStatusCardState();
}

class _AccountStatusCardState extends State<AccountStatusCard> {
  double? _fetchedAmount;
  String? _fetchedReading;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _fetchRemoteData(widget.userId!);
    }
  }

  Future<void> _fetchRemoteData(int userId) async {
    try {
      final billResp = await BackendApiService.getLatestAmountDue(userId);
      if (billResp['success'] == true) {
        _fetchedAmount = billResp['amount_due'] as double?;
      }

      final mrResp = await BackendApiService.getLatestMeterReading(userId);
      if (mrResp['success'] == true) {
        _fetchedReading = (mrResp['reading'] as String?) ?? '';
      }
    } finally {
      if (mounted) setState(() {});
    }
  }

  Color _getStatusColor() {
    switch (widget.status.toLowerCase()) {
      case 'current':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'due soon':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'overdue':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _formatCurrency(double amount) {
    return '₱${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final displayedAmount = (_fetchedAmount ?? widget.currentBill) ?? 0.0;
    final displayedReading = (_fetchedReading ?? widget.meterReading) ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${widget.customerName}',
                      style: AppTheme.lightTheme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Account: ${widget.accountNumber}',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.status.toUpperCase(),
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Bill',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  displayedAmount == 0.0
                      ? '__ __'
                      : _formatCurrency(displayedAmount),
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Due Date',
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.dueDate != null
                                ? _formatDate(widget.dueDate!)
                                : '-',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meter Reading',
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            displayedReading.isNotEmpty
                                ? '$displayedReading m³'
                                : '-',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
