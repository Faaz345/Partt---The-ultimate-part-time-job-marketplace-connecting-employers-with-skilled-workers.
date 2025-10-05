import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/job_model.dart';
import '../../../../core/helpers/notification_integration_helper.dart';

class JobApplicationScreen extends StatefulWidget {
  final JobModel job;
  
  const JobApplicationScreen({super.key, required this.job});

  @override
  State<JobApplicationScreen> createState() => _JobApplicationScreenState();
}

class _JobApplicationScreenState extends State<JobApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _coverLetterController = TextEditingController();
  bool _isLoading = false;
  bool _hasApplied = false;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyApplied();
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _checkIfAlreadyApplied() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final applications = await FirebaseFirestore.instance
        .collection('applications')
        .where('jobId', isEqualTo: widget.job.id)
        .where('workerId', isEqualTo: user.uid)
        .get();

    if (mounted) {
      setState(() {
        _hasApplied = applications.docs.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Apply for Job',
          style: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppConstants.backgroundColor,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppConstants.primaryColor,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildJobDetailsCard(),
                  if (!_hasApplied) _buildApplicationForm(),
                  if (_hasApplied) _buildAlreadyAppliedMessage(),
                ],
              ),
            ),
    );
  }

  Widget _buildJobDetailsCard() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.job.title,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            widget.job.managerCompany,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppConstants.textSecondary,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
          SizedBox(height: 16.h),
          _buildDetailRow(Icons.category, widget.job.category),
          SizedBox(height: 8.h),
          _buildDetailRow(Icons.location_on, widget.job.location),
          SizedBox(height: 8.h),
          _buildDetailRow(Icons.attach_money, widget.job.formattedSalary),
          SizedBox(height: 8.h),
          _buildDetailRow(Icons.access_time, widget.job.workingHours),
          SizedBox(height: 16.h),
          Text(
            'Description:',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            widget.job.description,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppConstants.textSecondary,
              fontFamily: AppConstants.fontFamily,
              height: 1.5,
            ),
          ),
          if (widget.job.requirements.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text(
              'Requirements:',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
            SizedBox(height: 8.h),
            ...widget.job.requirements.map((req) => Padding(
                  padding: EdgeInsets.only(bottom: 4.h, left: 8.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle,
                          size: 16.sp, color: AppConstants.successColor),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          req,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppConstants.textSecondary,
                            fontFamily: AppConstants.fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppConstants.primaryColor),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppConstants.textSecondary,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationForm() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cover Letter',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _coverLetterController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Tell the employer why you\'re a great fit for this job...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppConstants.primaryColor.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
                ),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please write a cover letter';
                }
                if (value.trim().length < 50) {
                  return 'Cover letter should be at least 50 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Submit Application',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppConstants.fontFamily,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAlreadyAppliedMessage() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppConstants.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppConstants.successColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: 48.sp,
            color: AppConstants.successColor,
          ),
          SizedBox(height: 16.h),
          Text(
            'Application Submitted',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppConstants.successColor,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You have already applied for this position. The employer will review your application.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppConstants.textSecondary,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You must be logged in to apply',
            style: TextStyle(fontFamily: AppConstants.fontFamily),
          ),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get worker details
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }

      final userData = userDoc.data()!;
      
      // Create application
      final applicationRef = FirebaseFirestore.instance.collection('applications').doc();
      
      await applicationRef.set({
        'jobId': widget.job.id,
        'workerId': user.uid,
        'workerName': userData['fullName'] ?? user.displayName ?? 'Unknown Worker',
        'workerEmail': userData['email'] ?? user.email ?? '',
        'workerPhone': userData['phone'] ?? '',
        'workerProfileImageUrl': userData['profileImageUrl'],
        'coverLetter': _coverLetterController.text.trim(),
        'status': 'pending',
        'appliedAt': FieldValue.serverTimestamp(),
        'statusUpdatedAt': null,
        'managerNotes': null,
        'managerId': widget.job.managerId,
        'jobTitle': widget.job.title,
        'jobCompany': widget.job.managerCompany,
      });

      // Update job applicant count
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.job.id)
          .update({
        'currentApplicants': FieldValue.increment(1),
        'applicantIds': FieldValue.arrayUnion([user.uid]),
      });
      
      // Send notification to manager
      await NotificationIntegrationHelper.notifyManagerAboutApplication(
        managerId: widget.job.managerId,
        jobId: widget.job.id,
        applicationId: applicationRef.id,
        workerName: userData['fullName'] ?? user.displayName ?? 'Unknown Worker',
        jobTitle: widget.job.title,
      );

      if (mounted) {
        setState(() {
          _hasApplied = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Application submitted successfully!',
              style: TextStyle(fontFamily: AppConstants.fontFamily),
            ),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error submitting application: ${e.toString()}',
              style: TextStyle(fontFamily: AppConstants.fontFamily),
            ),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}