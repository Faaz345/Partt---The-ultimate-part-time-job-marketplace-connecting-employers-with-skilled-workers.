import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../dashboard/presentation/screens/worker_dashboard_screen.dart';

class WorkerProfileSetupScreen extends StatefulWidget {
  const WorkerProfileSetupScreen({super.key});

  @override
  State<WorkerProfileSetupScreen> createState() => _WorkerProfileSetupScreenState();
}

class _WorkerProfileSetupScreenState extends State<WorkerProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  
  // Controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  final _aboutMeController = TextEditingController();
  
  // Form values
  String _selectedGender = AppConstants.genderOptions.first;
  String _selectedEducation = AppConstants.educationLevels.first;
  String _selectedExperience = AppConstants.experienceLevels.first;
  List<String> _selectedSkills = [];
  
  bool _isLoading = false;
  int _currentStep = 0;
  
  // Available skills for workers
  final List<String> _availableSkills = [
    'Customer Service',
    'Sales',
    'Food Service',
    'Cleaning',
    'Delivery',
    'Security',
    'Warehouse',
    'Retail',
    'Administrative',
    'Event Staff',
    'Data Entry',
    'Communication',
    'Teamwork',
    'Problem Solving',
    'Time Management',
    'Physical Strength',
    'Multitasking',
    'Cash Handling',
    'Inventory Management',
    'Equipment Operation'
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
    }
  }
  
  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Worker Profile Setup',
          style: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Stepper(
                currentStep: _currentStep,
                onStepTapped: (step) => setState(() => _currentStep = step),
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: Row(
                      children: [
                        if (details.stepIndex < 2)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                print('DEBUG: Next button clicked on step $_currentStep');
                                if (_validateCurrentStep()) {
                                  if (_currentStep < 2) {
                                    setState(() {
                                      _currentStep += 1;
                                    });
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.primaryColor,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                              ),
                              child: Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        if (details.stepIndex == 2)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.primaryColor,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                              ),
                              child: Text(
                                'Complete Setup',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        if (details.stepIndex > 0) ...[
                          SizedBox(width: 12.w),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                print('DEBUG: Previous button clicked');
                                if (_currentStep > 0) {
                                  setState(() {
                                    _currentStep -= 1;
                                  });
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppConstants.primaryColor),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                              ),
                              child: Text(
                                'Previous',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppConstants.primaryColor,
                                ),
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
                  _buildWorkExperienceStep(),
                  _buildSkillsStep(),
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
      content: Column(
        children: [
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person, color: AppConstants.primaryColor),
              labelStyle: TextStyle(fontFamily: AppConstants.fontFamily),
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
              labelStyle: TextStyle(fontFamily: AppConstants.fontFamily),
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
                    labelStyle: TextStyle(fontFamily: AppConstants.fontFamily),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age < 18 || age > 65) {
                      return 'Please enter a valid age (18-65)';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    labelStyle: TextStyle(fontFamily: AppConstants.fontFamily),
                  ),
                  items: AppConstants.genderOptions.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(
                        gender,
                        style: TextStyle(fontFamily: AppConstants.fontFamily),
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
              labelStyle: TextStyle(fontFamily: AppConstants.fontFamily),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your location';
              }
              return null;
            },
          ),
        ],
      ),
      isActive: _currentStep >= 0,
    );
  }
  
  Step _buildWorkExperienceStep() {
    return Step(
      title: Text(
        'Work Experience',
        style: TextStyle(
          fontFamily: AppConstants.fontFamily,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedEducation,
            decoration: InputDecoration(
              labelText: 'Education Level',
              prefixIcon: Icon(Icons.school, color: AppConstants.primaryColor),
              labelStyle: TextStyle(fontFamily: AppConstants.fontFamily),
            ),
            items: AppConstants.educationLevels.map((education) {
              return DropdownMenuItem(
                value: education,
                child: Text(
                  education,
                  style: TextStyle(fontFamily: AppConstants.fontFamily),
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedEducation = value!),
          ),
          SizedBox(height: 16.h),
          DropdownButtonFormField<String>(
            value: _selectedExperience,
            decoration: InputDecoration(
              labelText: 'Work Experience',
              prefixIcon: Icon(Icons.work, color: AppConstants.primaryColor),
              labelStyle: TextStyle(fontFamily: AppConstants.fontFamily),
            ),
            items: AppConstants.experienceLevels.map((experience) {
              return DropdownMenuItem(
                value: experience,
                child: Text(
                  experience,
                  style: TextStyle(fontFamily: AppConstants.fontFamily),
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedExperience = value!),
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _aboutMeController,
            decoration: InputDecoration(
              labelText: 'Tell us about yourself',
              hintText: 'Describe your work style, strengths, and what makes you a great worker...',
              prefixIcon: Icon(Icons.info, color: AppConstants.primaryColor),
              labelStyle: TextStyle(fontFamily: AppConstants.fontFamily),
            ),
            maxLines: 3,
            maxLength: 500,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please tell us about yourself';
              }
              if (value.length < 50) {
                return 'Please provide at least 50 characters';
              }
              return null;
            },
          ),
        ],
      ),
      isActive: _currentStep >= 1,
    );
  }
  
  Step _buildSkillsStep() {
    return Step(
      title: Text(
        'Skills & Preferences',
        style: TextStyle(
          fontFamily: AppConstants.fontFamily,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select your skills (minimum 3):',
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
          if (_selectedSkills.length < 3)
            Text(
              'Please select at least 3 skills',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12.sp,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
        ],
      ),
      isActive: _currentStep >= 2,
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
      if (age == null || age < 18 || age > 65) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid age (18-65)'),
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
    
    // For step 1 (Work Experience)
    if (_currentStep == 1) {
      print('DEBUG: Validating Work Experience');
      
      if (_aboutMeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please tell us about yourself'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      
      if (_aboutMeController.text.length < 50) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please provide at least 50 characters about yourself'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      
      print('DEBUG: All step 1 validations passed!');
    }
    
    // For step 2 (Skills) - no validation needed here, will be checked in _saveProfile
    return true;
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedSkills.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 3 skills'),
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
      
      final userModel = UserModel(
        id: user.uid,
        email: user.email!,
        fullName: _fullNameController.text.trim(),
        role: AppConstants.workerRole,
        phoneNumber: _phoneController.text.trim(),
        gender: _selectedGender,
        age: int.parse(_ageController.text),
        location: _locationController.text.trim(),
        education: _selectedEducation,
        experience: _selectedExperience,
        skills: _selectedSkills,
        aboutMe: _aboutMeController.text.trim(),
        isProfileComplete: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _authService.createUserProfile(user: userModel);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile setup completed successfully!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WorkerDashboardScreen()),
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