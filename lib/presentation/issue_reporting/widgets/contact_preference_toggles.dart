import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ContactPreferenceToggles extends StatelessWidget {
  final Map<String, bool> preferences;
  final Function(String, bool) onPreferenceChanged;

  const ContactPreferenceToggles({
    Key? key,
    required this.preferences,
    required this.onPreferenceChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contactMethods = [
      {'key': 'sms', 'label': 'SMS Updates', 'icon': 'sms'},
      {'key': 'email', 'label': 'Email Updates', 'icon': 'email'},
      {'key': 'push', 'label': 'Push Notifications', 'icon': 'notifications'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Preferences',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'How would you like to receive updates about this issue?',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        ...contactMethods.map((method) {
          final key = method['key'] as String;
          final isEnabled = preferences[key] ?? false;

          return Container(
            margin: EdgeInsets.only(bottom: 2.h),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: method['icon'] as String,
                  color: isEnabled
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 6.w,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    method['label'] as String,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: isEnabled
                          ? AppTheme.lightTheme.colorScheme.onSurface
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontWeight: isEnabled ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                Switch(
                  value: isEnabled,
                  onChanged: (value) => onPreferenceChanged(key, value),
                  activeColor: AppTheme.lightTheme.colorScheme.primary,
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
