import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../dashboard/presentation/screens/manager_dashboard_screen.dart';

class ManagerProfileSetupScreen extends StatefulWidget {
  const ManagerProfileSetupScreen({super.key});

  @override
  State<ManagerProfileSetupScreen> createState() => _ManagerProfileSetupScreenState();
}

class _ManagerProfileSetupScreenState extends State<ManagerProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  
  // Personal Information Controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  final _aboutMeController = TextEditingController();
  
  // Business Information Controllers
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _businessWebsiteController = TextEditingController();
  
  // Form values
  String _selectedGender = AppConstants.genderOptions.first;
  String _selectedEducation = AppConstants.educationLevels.first;
  String _selectedExperience = AppConstants.experienceLevels.first;
  String _selectedBusinessType = 'Retail';
  List<String> _selectedSkills = [];
  
  bool _isLoading = false;
  int _currentStep = 0;
  
  // Available business types
  final List<String> _businessTypes = [
    'Retail',
    'Restaurant',
    'Healthcare',
    'Technology',
    'Construction',
    'Manufacturing',
    'Transportation',
    'Hospitality',
    'Event Management',
    'Cleaning Services',
    'Security Services',
    'Logistics',
    'Other'
  ];
  
  // Management skills for managers
  final List<String> _availableSkills = [
    'Team Leadership',
    'Project Management',
    'Human Resources',
    'Budget Management',
    'Strategic Planning',
    'Operations Management',
    'Quality Control',
    'Training & Development',
    'Performance Management',
    'Scheduling',
    'Inventory Management',
    'Customer Relations',
    'Problem Solving',
    'Communication',
    'Decision Making',
    'Conflict Resolution',
    'Time Management',
    'Risk Management'
  ];
  
  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }
  
  void _initializeUserData() {
    final user = _authService.currentUser;
    if (user != null) {
      _fullNameController.text = user.displayName ?? '';
      _businessEmailController.text = user.email ?? '';
    }
  }
  
  @override
  void dispose() {
    // Dispose personal controllers
    _fullNameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _aboutMeController.dispose();
    
    // Dispose business controllers
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _businessDescriptionController.dispose();
    _businessPhoneController.dispose();
    _businessEmailController.dispose();
    _businessWebsiteController.dispose();
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manager Profile Setup',
          style: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConstants.primaryColor,
                AppConstants.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppConstants.backgroundColor,
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppConstants.primaryColor,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Setting up your profile...',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppConstants.textSecondary,
                      fontFamily: AppConstants.fontFamily,
                    ),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: Stepper(
                type: StepperType.vertical,
                currentStep: _currentStep,
                onStepTapped: (step) => setState(() => _currentStep = step),
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: EdgeInsets.only(top: 24.h, bottom: 12.h),
                    child: Row(
                      children: [
                        if (details.stepIndex < 2)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                print('======================================');
                                print('DEBUG: Next button CLICKED on step $_currentStep');
                                print('DEBUG: details.stepIndex = ${details.stepIndex}');
                                print('======================================');
                                final isValid = _validateCurrentStep();
                                print('DEBUG: Validation result = $isValid');
                                if (isValid) {
                                  print('DEBUG: Validation passed, moving to next step');
                                  if (_currentStep < 2) {
                                    setState(() {
                                      _currentStep += 1;
                                      print('DEBUG: New step = $_currentStep');
                                    });
                                  }
                                } else {
                                  print('DEBUG: Validation FAILED, staying on step $_currentStep');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.primaryColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 2,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Next',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppConstants.fontFamily,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Icon(Icons.arrow_forward, size: 20.sp),
                                ],
                              ),
                            ),
                          ),
                        if (details.stepIndex == 2)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.successColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 2,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, size: 18.sp),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Complete Setup',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppConstants.fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (details.stepIndex > 0) ...[
                          SizedBox(width: 12.w),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                print('======================================');
                                print('DEBUG: Previous button CLICKED');
                                print('DEBUG: Current step before = $_currentStep');
                                print('======================================');
                                if (_currentStep > 0) {
                                  setState(() {
                                    _currentStep -= 1;
                                    print('DEBUG: New step after decrement = $_currentStep');
                                  });
                                } else {
                                  print('DEBUG: Cannot go back, already at step 0');
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppConstants.primaryColor,
                                  width: 2,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_back,
                                    size: 20.sp,
                                    color: AppConstants.primaryColor,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Previous',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.primaryColor,
                                      fontFamily: AppConstants.fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
                steps: [
                  _buildPersonalInfoStep(),
                  _buildBusinessInfoStep(),
                  _buildManagementSkillsStep(),
                ],
              ),
            ),
    );
  }
  
  Step _buildPersonalInfoStep() {
    return Step(
      title: Text(
        'Personal Information',
        style: TextStyle(
          fontFamily: AppConstants.fontFamily,
          fontWeight: FontWeight.w600,
        ),
      ),
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      isActive: _currentStep >= 0,
      content: Column(
        children: [
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person, color: AppConstants.primaryColor),
              labelStyle: TextStyle(
                fontFamily: AppConstants.fontFamily,
                fontSize: 12.sp,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
            ),
            style: TextStyle(
              fontFamily: AppConstants.fontFamily,
              fontSize: 16.sp,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone, color: AppConstants.primaryColor),
              labelStyle: TextStyle(
                fontFamily: AppConstants.fontFamily,
                fontSize: 12.sp,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.cake, color: AppConstants.primaryColor),
                    labelStyle: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontSize: 12.sp,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age < 21 || age > 70) {
                      return 'Please enter a valid age (21-70)';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    labelStyle: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontSize: 12.sp,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  isExpanded: true,
                  items: AppConstants.genderOptions.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(
                        gender,
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamily,
                          fontSize: 16.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedGender = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Location (City, State)',
              prefixIcon: Icon(Icons.location_on, color: AppConstants.primaryColor),
              labelStyle: TextStyle(
                fontFamily: AppConstants.fontFamily,
                fontSize: 12.sp,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your location';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          DropdownButtonFormField<String>(
            value: _selectedExperience,
            decoration: InputDecoration(
              labelText: 'Management Experience',
              prefixIcon: Icon(Icons.work, color: AppConstants.primaryColor),
              labelStyle: TextStyle(
                fontFamily: AppConstants.fontFamily,
                fontSize: 12.sp,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
            ),
            isExpanded: true,
            items: AppConstants.experienceLevels.map((experience) {
              return DropdownMenuItem(
                value: experience,
                child: Text(
                  experience,
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamily,
                    fontSize: 16.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedExperience = value!),
          ),
        ],
      ),
    );
  }
  
  Step _buildBusinessInfoStep() {
    return Step(
      title: Text(
        'Business Information',
        style: TextStyle(
          fontFamily: AppConstants.fontFamily,
          fontWeight: FontWeight.w600,
        ),
      ),
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      isActive: _currentStep >= 1,
      content: Column(
        children: [
          TextFormField(
            controller: _businessNameController,
            decoration: InputDecoration(
              labelText: 'Business/Company Name',
              prefixIcon: Icon(Icons.business, color: AppConstants.primaryColor),
              labelStyle: TextStyle(fontFamily: AppConstants.fontFamily),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your business name';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          DropdownButtonFormField<String>(
            value: _selectedBusinessType,
            decoration: InputDecoration(
              labelText: 'Business Type/Industry',
              prefixIcon: Icon(Icons.category, color: AppConstants.primaryColor),
              labelStyle: TextStyle(fontFamily: AppConstants.fontFamily),
            ),
            isExpanded: true,
            items: _businessTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(
                  type,
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamily,
                    fontSize: 16.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedBusinessType = value!),
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _businessAddressController,
            decoration: InputDecoration(
              labelText: 'Business Address',
              prefixIcon: Icon(Icons.location_city, color: AppConstants.primaryColor),
              labelStyle: TextStyle(fontFamily: AppConstants.fontFamily),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your business address';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _businessPhoneController,
            decoration: InputDecoration(
              labelText: 'Business Phone',
              prefixIcon: Icon(Icons.business_center, color: AppConstants.primaryColor),
              labelStyle: TextStyle(fontFamily: AppConstants.fontFamily),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your business phone';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _businessEmailController,
            decoration: InputDecoration(
              labelText: 'Business Email',
              prefixIcon: Icon(Icons.email, color: AppConstants.primaryColor),
              labelStyle: TextStyle(fontFamily: AppConstants.fontFamily),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your business email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _businessWebsiteController,
            decoration: InputDecoration(
              labelText: 'Website (Optional)',
              prefixIcon: Icon(Icons.web, color: AppConstants.primaryColor),
              labelStyle: TextStyle(fontFamily: AppConstants.fontFamily),
            ),
            keyboardType: TextInputType.url,
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _businessDescriptionController,
            decoration: InputDecoration(
              labelText: 'Business Description',
              hintText: 'Describe your business, what you do, and what type of workers you need...',
              prefixIcon: Icon(Icons.description, color: AppConstants.primaryColor),
              labelStyle: TextStyle(fontFamily: AppConstants.fontFamily),
            ),
            maxLines: 3,
            maxLength: 500,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please describe your business';
              }
              if (value.length < 50) {
                return 'Please provide at least 50 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
  
  Step _buildManagementSkillsStep() {
    return Step(
      title: Text(
        'Management Skills',
        style: TextStyle(
          fontFamily: AppConstants.fontFamily,
          fontWeight: FontWeight.w600,
        ),
      ),
      state: StepState.indexed,
      isActive: _currentStep >= 2,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select your management skills (minimum 4):',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimary,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 4.h,
            children: _availableSkills.map((skill) {
              final isSelected = _selectedSkills.contains(skill);
              return FilterChip(
                label: Text(
                  skill,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppConstants.textPrimary,
                    fontFamily: AppConstants.fontFamily,
                    fontSize: 12.sp,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSkills.add(skill);
                    } else {
                      _selectedSkills.remove(skill);
                    }
                  });
                },
                selectedColor: AppConstants.primaryColor,
                checkmarkColor: Colors.white,
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),
          if (_selectedSkills.length < 4)
            Text(
              'Please select at least 4 management skills',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12.sp,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _aboutMeController,
            decoration: InputDecoration(
              labelText: 'About Your Management Style',
              hintText: 'Describe your management approach, leadership philosophy, and what makes you a great manager...',
              prefixIcon: Icon(Icons.supervisor_account, color: AppConstants.primaryColor),
              labelStyle: TextStyle(fontFamily: AppConstants.fontFamily),
            ),
            maxLines: 4,
            maxLength: 500,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please describe your management style';
              }
              if (value.length < 50) {
                return 'Please provide at least 50 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
  
  bool _validateCurrentStep() {
    print('DEBUG: Validating step $_currentStep');
    
    // For step 0 (Personal Information)
    if (_currentStep == 0) {
      print('DEBUG: Full Name: "${_fullNameController.text}"');
      print('DEBUG: Phone: "${_phoneController.text}"');
      print('DEBUG: Age: "${_ageController.text}"');
      print('DEBUG: Location: "${_locationController.text}"');
      print('DEBUG: Gender: "$_selectedGender"');
      print('DEBUG: Experience: "$_selectedExperience"');
      
      // Manually validate fields for step 0
      if (_fullNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter your full name'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      
      if (_phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter your phone number'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      
      if (_ageController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter your age'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      
      final age = int.tryParse(_ageController.text);
      if (age == null || age < 21 || age > 70) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid age (21-70)'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      
      if (_locationController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter your location'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      
      print('DEBUG: All step 0 validations passed!');
    }
    
    // For step 1 (Business Information)
    if (_currentStep == 1) {
      print('DEBUG: Validating Business Information');
      
      // Manually validate fields for step 1
      if (_businessNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter your business name'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      
      if (_businessAddressController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter your business address'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      
      if (_businessPhoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter your business phone'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      
      if (_businessEmailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter your business email'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      
      if (!_businessEmailController.text.contains('@')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid email'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      
      if (_businessDescriptionController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please describe your business'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      
      if (_businessDescriptionController.text.length < 50) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Business description must be at least 50 characters'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      
      print('DEBUG: All step 1 validations passed!');
    }
    
    // For step 2 (Management Skills), check if enough skills are selected
    if (_currentStep == 2) {
      if (_selectedSkills.length < 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select at least 4 management skills'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      if (!_formKey.currentState!.validate()) {
        return false;
      }
    }
    
    print('DEBUG: Validation passed for step $_currentStep');
    return true;
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedSkills.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 4 management skills'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('User not found');
      }
      
      final businessDetails = BusinessDetails(
        businessName: _businessNameController.text.trim(),
        businessType: _selectedBusinessType,
        businessAddress: _businessAddressController.text.trim(),
        businessDescription: _businessDescriptionController.text.trim(),
        businessPhone: _businessPhoneController.text.trim(),
        businessEmail: _businessEmailController.text.trim(),
        businessWebsite: _businessWebsiteController.text.trim().isEmpty 
            ? null 
            : _businessWebsiteController.text.trim(),
      );
      
      final userModel = UserModel(
        id: user.uid,
        email: user.email!,
        fullName: _fullNameController.text.trim(),
        role: AppConstants.managerRole,
        phoneNumber: _phoneController.text.trim(),
        gender: _selectedGender,
        age: int.parse(_ageController.text),
        location: _locationController.text.trim(),
        education: _selectedEducation,
        experience: _selectedExperience,
        skills: _selectedSkills,
        aboutMe: _aboutMeController.text.trim(),
        businessDetails: businessDetails,
        isProfileComplete: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _authService.createUserProfile(user: userModel);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Manager profile setup completed successfully!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ManagerDashboardScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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