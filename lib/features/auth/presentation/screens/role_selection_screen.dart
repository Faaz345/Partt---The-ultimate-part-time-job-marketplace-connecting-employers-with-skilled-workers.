import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';
import 'manager_login_screen.dart';
import 'worker_login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              SizedBox(height: 40.h),
              
              // App Logo
              Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: Image.asset(
                  AppConstants.logoMain,
                  width: 80.w,
                  height: 80.h,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        'P',
                        style: TextStyle(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                          fontFamily: AppConstants.fontFamily,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 32.h),
              
              // Welcome Text
              Text(
                'Welcome to Partt!',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: AppConstants.fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 16.h),
              
              Text(
                'Choose your role to get started',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontFamily: AppConstants.fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 60.h),
              
              // Role Selection Cards
              Expanded(
                child: Column(
                  children: [
                    // Worker Role Card
                    _buildRoleCard(
                      role: AppConstants.workerRole,
                      title: 'Worker',
                      subtitle: 'Find part-time jobs and opportunities',
                      icon: Icons.person,
                      isSelected: _selectedRole == AppConstants.workerRole,
                      onTap: () => setState(() => _selectedRole = AppConstants.workerRole),
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Manager Role Card
                    _buildRoleCard(
                      role: AppConstants.managerRole,
                      title: 'Manager',
                      subtitle: 'Post jobs and manage your team',
                      icon: Icons.business,
                      isSelected: _selectedRole == AppConstants.managerRole,
                      onTap: () => setState(() => _selectedRole = AppConstants.managerRole),
                    ),
                    
                    const Spacer(),
                    
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedRole != null ? _continueToProfileSetup : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.secondaryColor,
                          foregroundColor: AppConstants.darkModeBlack,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppConstants.fontFamily,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.secondaryColor : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppConstants.secondaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppConstants.primaryColor 
                    : AppConstants.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppConstants.primaryColor,
                size: 32.sp,
              ),
            ),
            
            SizedBox(width: 16.w),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppConstants.darkModeBlack : AppConstants.textPrimary,
                      fontFamily: AppConstants.fontFamily,
                    ),
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isSelected 
                          ? AppConstants.darkModeBlack.withValues(alpha: 0.7)
                          : AppConstants.textSecondary,
                      fontFamily: AppConstants.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppConstants.primaryColor,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  void _continueToProfileSetup() {
    if (_selectedRole == null) return;
    
    // Navigate to login screens based on selected role
    if (_selectedRole == AppConstants.workerRole) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const WorkerLoginScreen(),
        ),
      );
    } else if (_selectedRole == AppConstants.managerRole) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ManagerLoginScreen(),
        ),
      );
    }
  }
}