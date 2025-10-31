import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChargesBreakdown extends StatefulWidget {
  final List<Map<String, dynamic>> charges;

  const ChargesBreakdown({
    Key? key,
    required this.charges,
  }) : super(key: key);

  @override
  State<ChargesBreakdown> createState() => _ChargesBreakdownState();
}

class _ChargesBreakdownState extends State<ChargesBreakdown> {
  final Set<int> _expandedItems = <int>{};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.getElevationShadow(isLight: !isDark, elevation: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Charges Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                ),
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.charges.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.h),
            itemBuilder: (context, index) {
              final charge = widget.charges[index];
              final isExpanded = _expandedItems.contains(index);

              return _buildChargeItem(
                  context, charge, index, isExpanded, isDark);
            },
          ),
          SizedBox(height: 2.h),
          _buildTotalSection(context, isDark),
        ],
      ),
    );
  }

  Widget _buildChargeItem(
    BuildContext context,
    Map<String, dynamic> charge,
    int index,
    bool isExpanded,
    bool isDark,
  ) {
    final hasDetails =
        charge["details"] != null && (charge["details"] as List).isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
            .withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isDark ? AppTheme.dividerDark : AppTheme.dividerLight)
              .withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: hasDetails ? () => _toggleExpansion(index) : null,
            onLongPress: () => _showChargeDetails(context, charge),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          charge["name"] as String,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppTheme.textPrimaryDark
                                        : AppTheme.textPrimaryLight,
                                  ),
                        ),
                        if (charge["description"] != null) ...[
                          SizedBox(height: 0.5.h),
                          Text(
                            charge["description"] as String,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppTheme.textSecondaryDark
                                          : AppTheme.textSecondaryLight,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    '₱${(charge["amount"] as double).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight,
                        ),
                  ),
                  if (hasDetails) ...[
                    SizedBox(width: 2.w),
                    CustomIconWidget(
                      iconName: isExpanded ? 'expand_less' : 'expand_more',
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isExpanded && hasDetails) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(3.w, 0, 3.w, 3.w),
              child: Column(
                children: (charge["details"] as List).map<Widget>((detail) {
                  final detailMap = detail as Map<String, dynamic>;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 1.h),
                    child: Row(
                      children: [
                        SizedBox(width: 4.w),
                        CustomIconWidget(
                          iconName: 'fiber_manual_record',
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                          size: 8,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            detailMap["item"] as String,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppTheme.textSecondaryDark
                                          : AppTheme.textSecondaryLight,
                                    ),
                          ),
                        ),
                        Text(
                          '₱${(detailMap["amount"] as double).toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppTheme.textSecondaryDark
                                        : AppTheme.textSecondaryLight,
                                  ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalSection(BuildContext context, bool isDark) {
    final total = widget.charges.fold<double>(
      0.0,
      (sum, charge) => sum + (charge["amount"] as double),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Amount',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                ),
          ),
          Text(
            '₱${total.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                ),
          ),
        ],
      ),
    );
  }

  void _toggleExpansion(int index) {
    setState(() {
      if (_expandedItems.contains(index)) {
        _expandedItems.remove(index);
      } else {
        _expandedItems.add(index);
      }
    });
  }

  void _showChargeDetails(BuildContext context, Map<String, dynamic> charge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ChargeDetailsBottomSheet(charge: charge),
    );
  }
}

class _ChargeDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> charge;

  const _ChargeDetailsBottomSheet({
    Key? key,
    required this.charge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: 60.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  charge["name"] as String,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight,
                      ),
                ),
                SizedBox(height: 2.h),
                if (charge["fullDescription"] != null) ...[
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight,
                        ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    charge["fullDescription"] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                          height: 1.5,
                        ),
                  ),
                  SizedBox(height: 2.h),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.textPrimaryLight,
                          ),
                    ),
                    Text(
                      '₱${(charge["amount"] as double).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppTheme.primaryDark
                                : AppTheme.primaryLight,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
