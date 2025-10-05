import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../onboarding/presentation/screens/role_selection_screen.dart';
import '../../../dashboard/presentation/screens/worker_dashboard_screen.dart';
import '../../../dashboard/presentation/screens/manager_dashboard_screen.dart';
import '../../../profile/presentation/screens/worker_profile_setup_screen.dart';
import '../../../profile/presentation/screens/manager_profile_setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();

    _checkAuthAndNavigate();
  }

  Future<void> _deleteIncompleteProfileAndSignOut(String uid) async {
    try {
      // Delete user document from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .delete();
      
      // Delete Firebase Auth user
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }
      
      // Sign out
      await FirebaseAuth.instance.signOut();
      
      print('DEBUG: Incomplete profile deleted and user signed out');
    } catch (e) {
      print('DEBUG: Error deleting incomplete profile: $e');
      // If deletion fails, at least sign out the user
      try {
        await FirebaseAuth.instance.signOut();
      } catch (signOutError) {
        print('DEBUG: Error signing out: $signOutError');
      }
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // User not logged in, go to role selection
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const RoleSelectionScreen(),
        ),
      );
      return;
    }

    try {
      // User is logged in, check their role and profile status
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        // User document doesn't exist, sign out and go to role selection
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const RoleSelectionScreen(),
          ),
        );
        return;
      }

      final userData = userDoc.data()!;
      final role = userData['role'] as String?;
      final isProfileComplete = userData['isProfileComplete'] as bool? ?? false;

      if (!mounted) return;

      // Navigate based on role and profile status
      if (role == 'worker') {
        if (isProfileComplete) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const WorkerDashboardScreen(),
            ),
          );
        } else {
          // Profile incomplete, delete user data and restart from role selection
          await _deleteIncompleteProfileAndSignOut(user.uid);
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const RoleSelectionScreen(),
            ),
          );
        }
      } else if (role == 'manager') {
        if (isProfileComplete) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ManagerDashboardScreen(),
            ),
          );
        } else {
          // Profile incomplete, delete user data and restart from role selection
          await _deleteIncompleteProfileAndSignOut(user.uid);
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const RoleSelectionScreen(),
            ),
          );
        }
      } else {
        // Invalid role, sign out and go to role selection
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const RoleSelectionScreen(),
          ),
        );
      }
    } catch (e) {
      // Error occurred, go to role selection
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const RoleSelectionScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
              AppConstants.primaryColor.withValues(alpha: 0.05),
              AppConstants.primaryColor.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Image.asset(
                    'assets/images/partt_main_logo.png',
                    width: 380.w,
                    height: 200.h,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to text logo if image fails to load
                      return Text(
                        'Partt',
                        style: TextStyle(
                          fontSize: 64.sp,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                          letterSpacing: 2,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 24.h),

                // App Slogan
                Text(
                  'Part Time Work',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimary,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 60.h),

                // Loading Indicator
                SizedBox(
                  width: 45.w,
                  height: 45.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppConstants.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}