import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../core/app_export.dart';
import '../../services/issue_reporting_api_service.dart';
import './widgets/contact_preference_toggles.dart';
import './widgets/issue_category_selector.dart';
import './widgets/photo_attachment_section.dart';
import './widgets/priority_selector.dart';

class IssueReporting extends StatefulWidget {
  const IssueReporting({Key? key}) : super(key: key);

  @override
  State<IssueReporting> createState() => _IssueReportingState();
}

class _IssueReportingState extends State<IssueReporting> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedCategory;
  String? _selectedPriority;
  List<XFile> _attachedPhotos = [];
  Map<String, bool> _contactPreferences = {
    'sms': true,
    'email': false,
    'push': true,
  };

  bool _isSubmitting = false;
  bool _isDraftSaved = false;

  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDraftData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      _userData = json.decode(userDataString);
      _locationController.text = _userData!['address'] ?? '';
    }
    setState(() {}); // Update UI after loading data
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _loadDraftData() {
    // Simulate loading draft data
    setState(() {
      _isDraftSaved = false;
    });
  }

  void _saveDraft() {
    if (_selectedCategory != null || _descriptionController.text.isNotEmpty) {
      // Simulate saving draft
      setState(() {
        _isDraftSaved = true;
      });

      Fluttertoast.showToast(
        msg: "Draft saved successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        textColor: AppTheme.lightTheme.colorScheme.onSecondary,
      );
    }
  }

  bool _isFormValid() {
    return _selectedCategory != null &&
        _selectedPriority != null &&
        _descriptionController.text.trim().isNotEmpty;
  }

  String _generateTicketNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(7);
    return "AQ-${now.year}-$timestamp";
  }

  Map<String, String> _getEstimatedResolution() {
    switch (_selectedPriority) {
      case 'Emergency':
        return {
          'time': '2-4 hours',
          'description':
              'Emergency response team will be dispatched immediately'
        };
      case 'High':
        return {
          'time': '24-48 hours',
          'description': 'Priority service team will address this issue'
        };
      case 'Medium':
        return {
          'time': '3-5 business days',
          'description': 'Standard service response time'
        };
      case 'Low':
        return {
          'time': '5-7 business days',
          'description': 'Scheduled maintenance window'
        };
      default:
        return {
          'time': '3-5 business days',
          'description': 'Standard service response time'
        };
    }
  }

  Future<void> _submitReport() async {
    if (!_isFormValid()) {
      Fluttertoast.showToast(
        msg: "Please fill in all required fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: AppTheme.lightTheme.colorScheme.onError,
      );
      return;
    }

    if (_userData == null) {
      Fluttertoast.showToast(
        msg: "User data not available. Please login again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: AppTheme.lightTheme.colorScheme.onError,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = int.parse(_userData!['id'].toString());

      // For now, skip photo upload - would need to implement file upload
      List<String>? photoUrls;
      // TODO: Upload photos and get URLs

      final result = await IssueReportingApiService.submitIssueReport(
        userId: userId,
        category: _selectedCategory!,
        priority: _selectedPriority!,
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        contactPreferences: _contactPreferences,
        photoUrls: photoUrls,
      );

      if (result['success'] == true) {
        final ticketNumber = _generateTicketNumber();
        final resolution = _getEstimatedResolution();

        // Show success and navigate to confirmation
        _showSubmissionSuccess(ticketNumber, resolution);
      } else {
        Fluttertoast.showToast(
          msg:
              result['message'] ?? "Failed to submit report. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          textColor: AppTheme.lightTheme.colorScheme.onError,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to submit report. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: AppTheme.lightTheme.colorScheme.onError,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSubmissionSuccess(
      String ticketNumber, Map<String, String> resolution) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 6.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Report Submitted',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ticket Number',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ticketNumber,
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: ticketNumber));
                            Fluttertoast.showToast(
                              msg: "Ticket number copied",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                          },
                          child: CustomIconWidget(
                            iconName: 'copy',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 5.w,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Estimated Resolution Time',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                resolution['time']!,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                resolution['description']!,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 3.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary
                      .withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.secondary
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info',
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      size: 5.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'You will receive updates via your selected contact preferences.',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
              child: Text(
                'Back to Dashboard',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Report Issue',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        actions: [
          if (_isDraftSaved)
            Container(
              margin: EdgeInsets.only(right: 4.w),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'check',
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    size: 4.w,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Draft Saved',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account Information Card
                      if (_userData != null)
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'account_circle',
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    size: 6.w,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    'Account Information',
                                    style: AppTheme
                                        .lightTheme.textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Account Number',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: AppTheme.lightTheme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          _userData!["meter_number"]
                                                  as String? ??
                                              'N/A',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Customer Name',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: AppTheme.lightTheme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          _userData!["full_name"] as String? ??
                                              'Unknown',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 4.h),

                      // Issue Category Selection
                      IssueCategorySelector(
                        selectedCategory: _selectedCategory,
                        onCategorySelected: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                          _saveDraft();
                        },
                      ),

                      SizedBox(height: 4.h),

                      // Priority Selection
                      PrioritySelector(
                        selectedPriority: _selectedPriority,
                        onPrioritySelected: (priority) {
                          setState(() {
                            _selectedPriority = priority;
                          });
                          _saveDraft();
                        },
                      ),

                      SizedBox(height: 4.h),

                      // Description Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Issue Description *',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 5,
                            maxLength: 500,
                            decoration: InputDecoration(
                              hintText:
                                  'Please describe the issue in detail. Include when it started, how often it occurs, and any other relevant information...',
                              hintStyle: AppTheme
                                  .lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.7),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color:
                                      AppTheme.lightTheme.colorScheme.outline,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (value) => _saveDraft(),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please describe the issue';
                              }
                              if (value.trim().length < 10) {
                                return 'Please provide more details (minimum 10 characters)';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      // Location Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Service Address',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(3.w),
                                child: CustomIconWidget(
                                  iconName: 'location_on',
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  size: 5.w,
                                ),
                              ),
                              hintText: 'Enter service address',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      // Photo Attachment Section
                      PhotoAttachmentSection(
                        attachedPhotos: _attachedPhotos,
                        onPhotosChanged: (photos) {
                          setState(() {
                            _attachedPhotos = photos;
                          });
                          _saveDraft();
                        },
                      ),

                      SizedBox(height: 4.h),

                      // Contact Preferences
                      ContactPreferenceToggles(
                        preferences: _contactPreferences,
                        onPreferenceChanged: (key, value) {
                          setState(() {
                            _contactPreferences[key] = value;
                          });
                        },
                      ),

                      SizedBox(height: 10.h), // Extra space for bottom button
                    ],
                  ),
                ),
              ),
            ),

            // Fixed Submit Button
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isFormValid() && !_isSubmitting ? _submitReport : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFormValid()
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.3),
                      foregroundColor: _isFormValid()
                          ? AppTheme.lightTheme.colorScheme.onPrimary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: _isFormValid() ? 2 : 0,
                    ),
                    child: _isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 5.w,
                                height: 5.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Submitting Report...',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'send',
                                color: _isFormValid()
                                    ? AppTheme.lightTheme.colorScheme.onPrimary
                                    : AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                size: 5.w,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Submit Report',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color: _isFormValid()
                                      ? AppTheme
                                          .lightTheme.colorScheme.onPrimary
                                      : AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
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
