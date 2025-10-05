import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../features/dashboard/presentation/screens/manager_dashboard_screen.dart';
import '../../../../features/dashboard/presentation/screens/worker_dashboard_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String? selectedRole;
  
  const ProfileSetupScreen({
    super.key,
    this.selectedRole,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  
  // Personal Information Controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  final _aboutMeController = TextEditingController();
  
  // Business Information Controllers (for managers)
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _businessWebsiteController = TextEditingController();
  
  // Dropdown values
  String _selectedGender = AppConstants.genderOptions.first;
  String _selectedEducation = AppConstants.educationLevels.first;
  String _selectedExperience = AppConstants.experienceLevels.first;
  String _selectedBusinessType = 'Retail';
  List<String> _selectedSkills = [];
  
  bool _isLoading = false;
  int _currentStep = 0;
  bool get _isManager => widget.selectedRole == AppConstants.managerRole;
  
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
    // Dispose all controllers
    _fullNameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _aboutMeController.dispose();
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
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: Image.asset(
            AppConstants.logoMain,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.person_add,
                color: Colors.white,
                size: 24.sp,
              );
            },
          ),
        ),
        title: Text(
          'Profile Setup',
          style: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Prevent going back
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (details.stepIndex < 1)
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: details.onStepContinue,
                              child: const Text('Next'),
                            ),
                          ),
                        if (details.stepIndex == 1)
                          Expanded(
                            flex: 3,
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              child: const Text('Complete Setup'),
                            ),
                          ),
                        if (details.stepIndex > 0)
                          SizedBox(width: 12.w),
                        if (details.stepIndex > 0)
                          Expanded(
                            flex: 2,
                            child: TextButton(
                              onPressed: details.onStepCancel,
                              child: const Text('Previous'),
                            ),
                          ),
                      ],
                    ),
                  );
                },
                steps: _isManager 
                    ? [
                        _buildPersonalInfoStep(),
                        _buildBusinessInfoStep(),
                      ]
                    : [
                        _buildPersonalInfoStep(),
                        _buildWorkerInfoStep(),
                      ],
              ),
            ),
    );
  }
  
  Step _buildPersonalInfoStep() {
    return Step(
      title: const Text('Personal Information'),
      content: Column(
        children: [
          TextFormField(
            controller: _fullNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
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
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone),
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
                flex: 2,
                child: TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.cake),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age < 18 || age > 100) {
                      return 'Please enter a valid age (18-100)';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.person_outline),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  items: AppConstants.genderOptions.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(
                        gender,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              prefixIcon: Icon(Icons.location_on),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your location';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _aboutMeController,
            decoration: const InputDecoration(
              labelText: 'About Me',
              prefixIcon: Icon(Icons.info_outline),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please tell us about yourself';
              }
              return null;
            },
          ),
        ],
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    );
  }
  
  
  Step _buildBusinessInfoStep() {
    return Step(
      title: const Text('Business Information'),
      content: Column(
        children: [
          TextFormField(
            controller: _businessNameController,
            decoration: const InputDecoration(
              labelText: 'Business Name',
              prefixIcon: Icon(Icons.business),
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
            decoration: const InputDecoration(
              labelText: 'Business Type',
              prefixIcon: Icon(Icons.category),
            ),
            items: AppConstants.jobCategories.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBusinessType = value!;
              });
            },
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _businessAddressController,
            decoration: const InputDecoration(
              labelText: 'Business Address',
              prefixIcon: Icon(Icons.location_on),
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
            controller: _businessDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Business Description',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please describe your business';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _businessPhoneController,
            decoration: const InputDecoration(
              labelText: 'Business Phone (Optional)',
              prefixIcon: Icon(Icons.phone_in_talk),
            ),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _businessEmailController,
            decoration: const InputDecoration(
              labelText: 'Business Email',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter business email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _businessWebsiteController,
            decoration: const InputDecoration(
              labelText: 'Business Website (Optional)',
              prefixIcon: Icon(Icons.web),
            ),
            keyboardType: TextInputType.url,
          ),
        ],
      ),
      isActive: _currentStep >= 1,
      state: StepState.indexed,
    );
  }
  
  Step _buildWorkerInfoStep() {
    return Step(
      title: const Text('Worker Information'),
      content: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedEducation,
            decoration: const InputDecoration(
              labelText: 'Education Level',
              prefixIcon: Icon(Icons.school),
            ),
            items: AppConstants.educationLevels.map((education) {
              return DropdownMenuItem(
                value: education,
                child: Text(education),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedEducation = value!;
              });
            },
          ),
          SizedBox(height: 16.h),
          DropdownButtonFormField<String>(
            value: _selectedExperience,
            decoration: const InputDecoration(
              labelText: 'Experience Level',
              prefixIcon: Icon(Icons.work),
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
          ),
          SizedBox(height: 16.h),
          Text(
            'Select Skills (tap to add/remove)',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppConstants.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: AppConstants.jobCategories.map((skill) {
              final isSelected = _selectedSkills.contains(skill);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedSkills.remove(skill);
                    } else {
                      _selectedSkills.add(skill);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppConstants.primaryColor : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected ? AppConstants.primaryColor : Colors.grey,
                    ),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppConstants.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      isActive: _currentStep >= 1,
      state: StepState.indexed,
    );
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Create business details (only for managers)
      BusinessDetails? businessDetails;
      if (_isManager) {
        businessDetails = BusinessDetails(
          businessName: _businessNameController.text.trim(),
          businessType: _selectedBusinessType,
          businessAddress: _businessAddressController.text.trim(),
          businessDescription: _businessDescriptionController.text.trim(),
          businessPhone: _businessPhoneController.text.trim().isEmpty 
              ? null 
              : _businessPhoneController.text.trim(),
          businessEmail: _businessEmailController.text.trim(),
          businessWebsite: _businessWebsiteController.text.trim().isEmpty 
              ? null 
              : _businessWebsiteController.text.trim(),
        );
      }
      
      // Create user model
      final userModel = UserModel(
        id: user.uid,
        email: user.email!,
        fullName: _fullNameController.text.trim(),
        role: widget.selectedRole ?? AppConstants.workerRole,
        profileImageUrl: user.photoURL,
        phoneNumber: _phoneController.text.trim(),
        gender: _selectedGender,
        age: int.parse(_ageController.text.trim()),
        location: _locationController.text.trim(),
        education: _isManager ? 'Management' : _selectedEducation,
        experience: _isManager ? 'Business Owner/Manager' : _selectedExperience,
        skills: _isManager ? [_selectedBusinessType] : _selectedSkills,
        aboutMe: _aboutMeController.text.trim(),
        businessDetails: businessDetails,
        isProfileComplete: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save to Firestore
      await _authService.createUserProfile(user: userModel);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.successProfileUpdated),
            backgroundColor: AppConstants.successColor,
          ),
        );
        
        // Navigate to appropriate dashboard
        if (_isManager) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ManagerDashboardScreen(),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const WorkerDashboardScreen(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
