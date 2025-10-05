import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';
import '../../../onboarding/presentation/screens/role_selection_screen.dart';
import '../../../dashboard/presentation/screens/worker_dashboard_screen.dart';
import '../../../dashboard/presentation/screens/manager_dashboard_screen.dart';
import '../../../profile/presentation/screens/profile_setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2)); // Show splash for 2 seconds
    
    if (mounted) {
      _navigateBasedOnAuthState();
    }
  }

  void _navigateBasedOnAuthState() {
    final User? currentUser = _authService.currentUser;
    
    if (currentUser == null) {
      // User not authenticated, show onboarding or login
      _navigateToOnboarding();
    } else {
      // User is authenticated, check profile completion
      _checkUserProfile(currentUser.uid);
    }
  }

  void _navigateToOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  void _navigateToRoleSelection() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
    );
  }

  Future<void> _checkUserProfile(String userId) async {
    try {
      final userProfile = await _authService.getUserProfile(userId);
      
      if (userProfile == null) {
        // Profile doesn't exist, navigate to role selection
        _navigateToRoleSelection();
      } else if (!userProfile.isProfileComplete) {
        // Profile exists but incomplete, navigate to role selection
        _navigateToRoleSelection();
      } else {
        // Profile is complete, navigate to appropriate dashboard
        if (userProfile.isWorker) {
          _navigateToWorkerDashboard();
        } else {
          _navigateToManagerDashboard();
        }
      }
    } catch (e) {
      // Error occurred, navigate to role selection
      _navigateToRoleSelection();
    }
  }

  void _navigateToWorkerDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const WorkerDashboardScreen()),
    );
  }

  void _navigateToManagerDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ManagerDashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey.shade50,
              Colors.grey.shade100,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Image.asset(
                'assets/images/partt_main_logo.png',
                width: 280.w,
                height: 120.h,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('Splash Error loading logo: $error');
                  // Fallback to Partt text logo if image fails to load
                  return Text(
                    'Partt',
                    style: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                      fontFamily: AppConstants.fontFamily,
                    ),
                  );
                },
              ),
              
              SizedBox(height: 40.h),
              
              // App Tagline
              Text(
                'Connect. Work. Grow.',
                style: TextStyle(
                  fontFamily: AppConstants.fontFamily,
                  fontSize: 18.sp,
                  color: AppConstants.textSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              
              SizedBox(height: 60.h),
              
              // Loading Indicator
              SizedBox(
                width: 40.w,
                height: 40.h,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                  strokeWidth: 3.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
