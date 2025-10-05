import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../onboarding/presentation/screens/role_selection_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final authService = AuthService();
  String _userRole = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          final role = userDoc.data()?['role'] as String?;
          setState(() {
            _userRole = role == 'worker' ? 'Worker' : 'Manager';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _userRole = 'User';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.h,
            floating: false,
            pinned: true,
            backgroundColor: AppConstants.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
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
                child: _buildProfileHeader(user),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: _buildProfileOptions(context, authService),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: CircleAvatar(
                radius: 40.r,
                backgroundColor: Colors.white,
                backgroundImage: user?.photoURL != null 
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null 
                    ? Icon(
                        Icons.person,
                        size: 40.sp,
                        color: AppConstants.primaryColor,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              user?.displayName ?? _userRole,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              user?.email ?? 'user@example.com',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white.withOpacity(0.9),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 18.w,
                      height: 18.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _userRole,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context, AuthService authService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Account Settings'),
        SizedBox(height: 8.h),
        _buildSettingsCard([
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () => _editProfile(context),
            color: AppConstants.primaryColor,
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () => _changePassword(context),
            color: AppConstants.primaryColor,
          ),
        ]),
        
        SizedBox(height: 24.h),
        _buildSectionHeader('Preferences'),
        SizedBox(height: 8.h),
        _buildSettingsCard([
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () => _manageNotifications(context),
            color: AppConstants.secondaryColor,
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English (US)',
            onTap: () => _changeLanguage(context),
            color: AppConstants.secondaryColor,
          ),
        ]),
        
        SizedBox(height: 24.h),
        _buildSectionHeader('Support'),
        SizedBox(height: 8.h),
        _buildSettingsCard([
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Help Center',
            subtitle: 'Get help and FAQs',
            onTap: () => _openHelpCenter(context),
            color: Colors.blue,
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          _buildSettingsTile(
            icon: Icons.feedback_outlined,
            title: 'Send Feedback',
            subtitle: 'Share your thoughts',
            onTap: () => _sendFeedback(context),
            color: Colors.blue,
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Version ${AppConstants.appVersion}',
            onTap: () => _showAboutDialog(context),
            color: Colors.blue,
          ),
        ]),
        
        SizedBox(height: 24.h),
        _buildSectionHeader('Actions'),
        SizedBox(height: 8.h),
        _buildSettingsCard([
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () => _showLogoutDialog(context, authService),
            color: AppConstants.warningColor,
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          _buildSettingsTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            onTap: () => _showDeleteAccountDialog(context, authService),
            color: AppConstants.errorColor,
          ),
        ]),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: AppConstants.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: color, size: 22.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13.sp,
          color: AppConstants.textSecondary,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  // Action Methods
  void _editProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Edit Profile feature coming soon!'),
        backgroundColor: AppConstants.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _changePassword(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password reset email sent to ${user.email}'),
              backgroundColor: AppConstants.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppConstants.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _manageNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification settings coming soon!'),
        backgroundColor: AppConstants.secondaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _changeLanguage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Language selection coming soon!'),
        backgroundColor: AppConstants.secondaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openHelpCenter(BuildContext context) async {
    const url = 'https://partt.app/help';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Help Center coming soon!'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _sendFeedback(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = 'support@partt.app';
    final subject = 'Feedback from ${user?.email ?? "User"}';
    final url = 'mailto:$email?subject=${Uri.encodeComponent(subject)}';
    
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open email client'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Icon(
        Icons.business_center,
        size: 48.sp,
        color: AppConstants.primaryColor,
      ),
      children: [
        Text(
          'Part Time Work - Connect with part-time job opportunities',
          style: TextStyle(fontSize: 14.sp),
        ),
        SizedBox(height: 16.h),
        Text(
          '© 2024 Partt. All rights reserved.',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Row(
          children: [
            Icon(Icons.logout, color: AppConstants.warningColor),
            SizedBox(width: 12.w),
            const Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await authService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AppConstants.errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.warningColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (dialogContext) => _DeleteAccountDialog(parentContext: context),
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  final BuildContext parentContext;

  const _DeleteAccountDialog({Key? key, required this.parentContext}) : super(key: key);

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isDeleting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(
          content: const Text('No user found. Please log in again.'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    // Check if user signed in with Google
    final isGoogleUser = user.providerData.any(
      (provider) => provider.providerId == 'google.com',
    );

    // If user signed in with email/password, require password
    if (!isGoogleUser) {
      final password = _passwordController.text;
      if (password.isEmpty) {
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          SnackBar(
            content: const Text('Please enter your password'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
        return;
      }
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      print('Starting account deletion for user: ${user.uid}');
      
      // Re-authenticate based on sign-in method
      if (isGoogleUser) {
        print('User signed in with Google, re-authenticating...');
        // For Google users, we need to re-authenticate with Google
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        
        if (googleUser == null) {
          print('User cancelled Google sign-in');
          // User cancelled
          setState(() {
            _isDeleting = false;
          });
          return;
        }
        
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
        print('Google re-authentication successful');
      } else {
        print('User signed in with email/password, re-authenticating...');
        // For email/password users
        final password = _passwordController.text;
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        print('Email/password re-authentication successful');
      }

      // Delete user data from Firestore
      print('Deleting user document from Firestore...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();
      print('User document deleted');

      // Delete applications
      print('Deleting user applications...');
      final applications = await FirebaseFirestore.instance
          .collection('applications')
          .where('workerId', isEqualTo: user.uid)
          .get();
      print('Found ${applications.docs.length} applications to delete');
      for (var doc in applications.docs) {
        await doc.reference.delete();
      }
      print('Applications deleted');

      // Delete jobs if manager
      print('Deleting user jobs...');
      final jobs = await FirebaseFirestore.instance
          .collection('jobs')
          .where('managerId', isEqualTo: user.uid)
          .get();
      print('Found ${jobs.docs.length} jobs to delete');
      for (var doc in jobs.docs) {
        await doc.reference.delete();
      }
      print('Jobs deleted');

      // Delete Firebase Auth account
      print('Deleting Firebase Auth account...');
      await user.delete();
      print('Firebase Auth account deleted successfully!');

      if (mounted && widget.parentContext.mounted) {
        Navigator.of(context).pop(); // Close password dialog
        Navigator.of(widget.parentContext).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
          (route) => false,
        );
        
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          SnackBar(
            content: const Text('Account deleted successfully'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    } catch (e) {
      print('Delete account error: $e');
      
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
        
        String errorMessage = 'An error occurred';
        
        if (e.toString().contains('permission-denied')) {
          errorMessage = 'Firestore permissions error. Please contact support to delete your account.';
        } else if (e.toString().contains('wrong-password') || e.toString().contains('invalid-credential')) {
          errorMessage = 'Incorrect password. Please try again.';
        } else if (e.toString().contains('too-many-requests')) {
          errorMessage = 'Too many attempts. Please try again later.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Check your connection.';
        } else if (e.toString().contains('user-not-found')) {
          errorMessage = 'User not found. Please log in again.';
        } else if (e.toString().contains('requires-recent-login')) {
          errorMessage = 'Please log out and log in again before deleting your account.';
        } else {
          errorMessage = 'Error: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppConstants.errorColor,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isGoogleUser = user?.providerData.any(
      (provider) => provider.providerId == 'google.com',
    ) ?? false;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      title: Row(
        children: [
          Icon(Icons.warning, color: AppConstants.errorColor),
          SizedBox(width: 12.w),
          const Text('Delete Account'),
        ],
      ),
      content: _isDeleting
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppConstants.primaryColor),
                SizedBox(height: 16.h),
                const Text('Deleting your account...'),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This action cannot be undone. All your data will be permanently deleted.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                if (isGoogleUser)
                  const Text('Click "Delete Account" to confirm and re-authenticate with Google.'),
                if (!isGoogleUser)
                  const Text('Please enter your password to confirm:'),
                if (!isGoogleUser)
                  SizedBox(height: 12.h),
                if (!isGoogleUser)
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
              ],
            ),
      actions: _isDeleting
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _deleteAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.errorColor,
                ),
                child: const Text('Delete Account'),
              ),
            ],
    );
  }
}
