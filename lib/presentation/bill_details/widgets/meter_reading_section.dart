import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MeterReadingSection extends StatelessWidget {
  final Map<String, dynamic> meterData;

  const MeterReadingSection({
    Key? key,
    required this.meterData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final photos = meterData["photos"] as List;

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
            'Meter Reading',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildReadingItem(
                  context,
                  'Current Reading',
                  '${meterData["currentReading"]} m³',
                  isDark,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildReadingItem(
                  context,
                  'Previous Reading',
                  '${meterData["previousReading"]} m³',
                  isDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildConsumptionInfo(context, isDark),
          if (photos.isNotEmpty) ...[
            SizedBox(height: 3.h),
            Text(
              'Meter Photos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
            ),
            SizedBox(height: 1.h),
            _buildPhotoGallery(context, photos),
          ],
        ],
      ),
    );
  }

  Widget _buildReadingItem(
      BuildContext context, String label, String value, bool isDark) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
            .withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
              .withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsumptionInfo(BuildContext context, bool isDark) {
    final consumption = (meterData["currentReading"] as int) -
        (meterData["previousReading"] as int);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.successDark : AppTheme.successLight)
            .withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isDark ? AppTheme.successDark : AppTheme.successLight)
              .withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'water_drop',
            color: isDark ? AppTheme.successDark : AppTheme.successLight,
            size: 24,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Water Consumption',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight,
                      ),
                ),
                Text(
                  '$consumption m³ this month',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.successDark
                            : AppTheme.successLight,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery(BuildContext context, List photos) {
    return SizedBox(
      height: 20.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index] as Map<String, dynamic>;
          return GestureDetector(
            onTap: () => _showFullScreenImage(context, photo),
            child: Container(
              width: 30.w,
              margin: EdgeInsets.only(right: 3.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: AppTheme.getElevationShadow(
                  isLight: Theme.of(context).brightness == Brightness.light,
                  elevation: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: photo["url"] as String,
                  width: 30.w,
                  height: 20.h,
                  fit: BoxFit.cover,
                  semanticLabel: photo["semanticLabel"] as String,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, Map<String, dynamic> photo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: CustomImageWidget(
                imageUrl: photo["url"] as String,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
                semanticLabel: photo["semanticLabel"] as String,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
