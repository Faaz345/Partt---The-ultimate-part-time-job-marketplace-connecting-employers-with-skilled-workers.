import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../dashboard/presentation/screens/worker_dashboard_screen.dart';
import '../../../profile/presentation/screens/worker_profile_setup_screen.dart';
import 'worker_signup_screen.dart';

class WorkerLoginScreen extends StatefulWidget {
  const WorkerLoginScreen({super.key});

  @override
  State<WorkerLoginScreen> createState() => _WorkerLoginScreenState();
}

class _WorkerLoginScreenState extends State<WorkerLoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppConstants.primaryColor,
              AppConstants.primaryColor.withOpacity(0.8),
              AppConstants.darkBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(),
                      SizedBox(height: 48.h),
                      _buildLoginCard(),
                      SizedBox(height: 24.h),
                      _buildSignupPrompt(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Icon(
            Icons.work_outline,
            size: 48.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Worker Login',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: AppConstants.fontFamily,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Sign in to find your next opportunity',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white.withOpacity(0.9),
            fontFamily: AppConstants.fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30.r,
            offset: Offset(0, 15.h),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmailField(),
            SizedBox(height: 20.h),
            _buildPasswordField(),
            SizedBox(height: 12.h),
            _buildForgotPassword(),
            SizedBox(height: 32.h),
            _buildLoginButton(),
            SizedBox(height: 20.h),
            _buildDivider(),
            SizedBox(height: 20.h),
            _buildGoogleSignInButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(
        fontSize: 16.sp,
        color: AppConstants.textPrimary,
        fontFamily: AppConstants.fontFamily,
      ),
      decoration: InputDecoration(
        labelText: 'Email Address',
        hintText: 'worker@example.com',
        prefixIcon: Icon(Icons.email_outlined, color: AppConstants.primaryColor),
        labelStyle: TextStyle(
          color: AppConstants.textSecondary,
          fontFamily: AppConstants.fontFamily,
        ),
        filled: true,
        fillColor: AppConstants.backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: AppConstants.errorColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(
        fontSize: 16.sp,
        color: AppConstants.textPrimary,
        fontFamily: AppConstants.fontFamily,
      ),
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: '••••••••',
        prefixIcon: Icon(Icons.lock_outline, color: AppConstants.primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppConstants.textSecondary,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        labelStyle: TextStyle(
          color: AppConstants.textSecondary,
          fontFamily: AppConstants.fontFamily,
        ),
        filled: true,
        fillColor: AppConstants.backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: AppConstants.errorColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: Implement forgot password
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Forgot password feature coming soon!')),
          );
        },
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: AppConstants.primaryColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            fontFamily: AppConstants.fontFamily,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 18.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 0,
        shadowColor: AppConstants.primaryColor.withOpacity(0.3),
      ),
      child: _isLoading
          ? SizedBox(
              height: 20.h,
              width: 20.w,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              'Sign In',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
    );
  }

  Widget _buildSignupPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 15.sp,
            fontFamily: AppConstants.fontFamily,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WorkerSignupScreen()),
            );
          },
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: AppConstants.secondaryColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppConstants.textSecondary.withOpacity(0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppConstants.textSecondary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppConstants.textSecondary.withOpacity(0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _handleGoogleSignIn,
      icon: Image.asset(
        'assets/images/google_logo.png',
        height: 24.h,
        width: 24.w,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.g_mobiledata,
            size: 28.sp,
            color: AppConstants.primaryColor,
          );
        },
      ),
      label: Text(
        'Continue with Google',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppConstants.darkBackground,
          fontFamily: AppConstants.fontFamily,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        side: BorderSide(
          color: AppConstants.primaryColor.withOpacity(0.3),
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential == null) {
        setState(() => _isLoading = false);
        return;
      }

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to get user information');
      }

      // Check if user exists in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (userDoc.exists) {
        // Existing user - check role
        final userData = userDoc.data()!;
        final role = userData['role'] as String?;

        if (role != null && role != AppConstants.workerRole) {
          await FirebaseAuth.instance.signOut();
          throw Exception('This account is registered as a $role. Please use the $role login.');
        }

        // Check if profile is complete
        final userProfile = await _authService.getUserProfile(user.uid);
        
        if (userProfile != null && userProfile.isProfileComplete) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const WorkerDashboardScreen()),
            (route) => false,
          );
        } else {
          // Profile incomplete, delete user data and go back to role selection
          try {
            // Delete user document from Firestore
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .delete();
            
            // Delete Firebase Auth user
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              await currentUser.delete();
            }
            
            // Sign out
            await FirebaseAuth.instance.signOut();
            
            if (!mounted) return;
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Your previous signup was incomplete. Please sign up again.'),
                backgroundColor: AppConstants.primaryColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            );
            
            // Go back to previous screen (role selection will be shown)
            Navigator.of(context).pop();
          } catch (deleteError) {
            print('Error deleting incomplete profile: $deleteError');
            // If deletion fails, at least sign out
            await FirebaseAuth.instance.signOut();
            if (!mounted) return;
            Navigator.of(context).pop();
          }
        }
      } else {
        // New user - create worker account
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'email': user.email,
          'role': AppConstants.workerRole,
          'isProfileComplete': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WorkerProfileSetupScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.signInWithRole(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: AppConstants.workerRole,
      );

      if (result != null && mounted) {
        // Check if profile is complete
        final userProfile = await _authService.getUserProfile(result.user!.uid);
        
        if (userProfile != null && userProfile.isProfileComplete) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const WorkerDashboardScreen()),
            (route) => false,
          );
        } else {
          // Profile incomplete, delete user data and go back to role selection
          try {
            // Delete user document from Firestore
            await FirebaseFirestore.instance
                .collection('users')
                .doc(result.user!.uid)
                .delete();
            
            // Delete Firebase Auth user
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              await currentUser.delete();
            }
            
            // Sign out
            await FirebaseAuth.instance.signOut();
            
            if (!mounted) return;
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Your previous signup was incomplete. Please sign up again.'),
                backgroundColor: AppConstants.primaryColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            );
            
            // Go back to previous screen (role selection will be shown)
            Navigator.of(context).pop();
          } catch (deleteError) {
            print('Error deleting incomplete profile: $deleteError');
            // If deletion fails, at least sign out
            await FirebaseAuth.instance.signOut();
            if (!mounted) return;
            Navigator.of(context).pop();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
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