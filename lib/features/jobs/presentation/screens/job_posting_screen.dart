import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/interstitial_ad_helper.dart';
import '../../data/models/job_model.dart';

class JobPostingScreen extends StatefulWidget {
  const JobPostingScreen({super.key});

  @override
  State<JobPostingScreen> createState() => _JobPostingScreenState();
}

class _JobPostingScreenState extends State<JobPostingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _locationController = TextEditingController();
  final _requirementsController = TextEditingController();
  
  String _selectedCategory = AppConstants.jobCategories.first;
  String _selectedExperience = AppConstants.experienceLevels.first;
  bool _isRemote = false;
  bool _isPartTime = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Preload interstitial ad
    InterstitialAdHelper.loadAd();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _locationController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post New Job',
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
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Job Details'),
                    SizedBox(height: 16.h),
                    _buildJobTitleField(),
                    SizedBox(height: 16.h),
                    _buildCategoryDropdown(),
                    SizedBox(height: 16.h),
                    _buildDescriptionField(),
                    SizedBox(height: 24.h),
                    
                    _buildSectionTitle('Requirements'),
                    SizedBox(height: 16.h),
                    _buildRequirementsField(),
                    SizedBox(height: 16.h),
                    _buildExperienceDropdown(),
                    SizedBox(height: 24.h),
                    
                    _buildSectionTitle('Job Type & Location'),
                    SizedBox(height: 16.h),
                    _buildJobTypeToggles(),
                    SizedBox(height: 16.h),
                    _buildLocationField(),
                    SizedBox(height: 16.h),
                    _buildSalaryField(),
                    SizedBox(height: 32.h),
                    
                    _buildPostJobButton(),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppConstants.primaryColor,
        fontFamily: AppConstants.fontFamily,
      ),
    );
  }
  
  Widget _buildJobTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Job Title',
        prefixIcon: Icon(Icons.work, color: AppConstants.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppConstants.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter job title';
        }
        return null;
      },
    );
  }
  
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Job Category',
        prefixIcon: Icon(Icons.category, color: AppConstants.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppConstants.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
      ),
      items: AppConstants.jobCategories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }
  
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Job Description',
        prefixIcon: Icon(Icons.description, color: AppConstants.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppConstants.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter job description';
        }
        return null;
      },
    );
  }
  
  Widget _buildRequirementsField() {
    return TextFormField(
      controller: _requirementsController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Requirements',
        prefixIcon: Icon(Icons.checklist, color: AppConstants.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppConstants.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter job requirements';
        }
        return null;
      },
    );
  }
  
  Widget _buildExperienceDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedExperience,
      decoration: InputDecoration(
        labelText: 'Required Experience',
        prefixIcon: Icon(Icons.trending_up, color: AppConstants.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppConstants.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
      ),
      items: AppConstants.experienceLevels.map((experience) {
        return DropdownMenuItem(
          value: experience,
          child: Text(experience),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedExperience = value!;
        });
      },
    );
  }
  
  Widget _buildJobTypeToggles() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Part-time Job',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppConstants.textPrimary,
                        fontFamily: AppConstants.fontFamily,
                      ),
                    ),
                    Switch(
                      value: _isPartTime,
                      onChanged: (value) => setState(() => _isPartTime = value),
                      activeColor: AppConstants.secondaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Remote Work',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppConstants.textPrimary,
                        fontFamily: AppConstants.fontFamily,
                      ),
                    ),
                    Switch(
                      value: _isRemote,
                      onChanged: (value) => setState(() => _isRemote = value),
                      activeColor: AppConstants.secondaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      enabled: !_isRemote,
      decoration: InputDecoration(
        labelText: _isRemote ? 'Remote Job' : 'Job Location',
        prefixIcon: Icon(
          _isRemote ? Icons.home : Icons.location_on, 
          color: AppConstants.primaryColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppConstants.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        filled: _isRemote,
        fillColor: _isRemote ? Colors.grey[100] : null,
      ),
      validator: (value) {
        if (!_isRemote && (value == null || value.isEmpty)) {
          return 'Please enter job location';
        }
        return null;
      },
    );
  }
  
  Widget _buildSalaryField() {
    return TextFormField(
      controller: _salaryController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Salary (per hour)',
        prefixIcon: Icon(Icons.attach_money, color: AppConstants.primaryColor),
        prefixText: '\$',
        suffixText: '/hour',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppConstants.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter hourly salary';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter valid salary amount';
        }
        return null;
      },
    );
  }
  
  Widget _buildPostJobButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _postJob,
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
          'Post Job',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: AppConstants.fontFamily,
          ),
        ),
      ),
    );
  }
  
  void _postJob() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('You must be logged in to post a job');
      }
      
      // Get user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }
      
      final userData = userDoc.data()!;
      final managerName = userData['fullName'] ?? user.displayName ?? 'Unknown Manager';
      final managerCompany = userData['companyName'] ?? 'Company';
      
      // Parse requirements (split by newlines or commas)
      final requirements = _requirementsController.text
          .split(RegExp(r'[\n,]'))
          .map((r) => r.trim())
          .where((r) => r.isNotEmpty)
          .toList();
      
      // Create job document in Firestore
      final jobRef = FirebaseFirestore.instance.collection('jobs').doc();
      
      final jobData = {
        'managerId': user.uid,
        'managerName': managerName,
        'managerCompany': managerCompany,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'location': _isRemote ? 'Remote' : _locationController.text.trim(),
        'latitude': null,
        'longitude': null,
        'hourlyRate': double.parse(_salaryController.text),
        'workingHours': _isPartTime ? 'Part-time' : 'Full-time',
        'startDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
        'endDate': null,
        'maxApplicants': 10,
        'currentApplicants': 0,
        'requirements': requirements,
        'benefits': [],
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'termsAndConditions': 'Standard terms and conditions apply.',
        'isUrgent': false,
        'applicantIds': [],
        'shortlistedApplicantIds': [],
        'acceptedApplicantIds': [],
      };
      
      await jobRef.set(jobData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Job posted successfully!',
              style: TextStyle(fontFamily: AppConstants.fontFamily),
            ),
            backgroundColor: AppConstants.successColor,
          ),
        );
        
        // Show interstitial ad after successful job posting
        await InterstitialAdHelper.showAd();
        
        // Clear form
        _titleController.clear();
        _descriptionController.clear();
        _salaryController.clear();
        _locationController.clear();
        _requirementsController.clear();
        setState(() {
          _selectedCategory = AppConstants.jobCategories.first;
          _selectedExperience = AppConstants.experienceLevels.first;
          _isRemote = false;
          _isPartTime = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error posting job: ${e.toString()}',
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