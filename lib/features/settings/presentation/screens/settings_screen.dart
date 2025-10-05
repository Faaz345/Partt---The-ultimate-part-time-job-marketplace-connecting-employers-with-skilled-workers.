import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.sp),
        children: [
          _buildSettingsSection(
            'General',
            [
              _buildSettingsTile(
                Icons.business_outlined,
                'Company Settings',
                'Manage company information and preferences',
                () => _showComingSoon(context, 'Company Settings'),
              ),
              _buildSettingsTile(
                Icons.language_outlined,
                'Language',
                'English',
                () => _showComingSoon(context, 'Language Settings'),
              ),
              _buildSettingsTile(
                Icons.palette_outlined,
                'Theme',
                'Light Mode',
                () => _showComingSoon(context, 'Theme Settings'),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _buildSettingsSection(
            'Employee Management',
            [
              _buildSettingsTile(
                Icons.people_outline,
                'Employee Roles',
                'Configure employee roles and permissions',
                () => _showComingSoon(context, 'Employee Roles'),
              ),
              _buildSettingsTile(
                Icons.access_time_outlined,
                'Work Hours',
                'Set standard work hours and schedules',
                () => _showComingSoon(context, 'Work Hours'),
              ),
              _buildSettingsTile(
                Icons.event_busy_outlined,
                'Leave Policy',
                'Configure leave types and policies',
                () => _showComingSoon(context, 'Leave Policy'),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _buildSettingsSection(
            'Payroll',
            [
              _buildSettingsTile(
                Icons.attach_money_outlined,
                'Salary Structure',
                'Configure salary components and deductions',
                () => _showComingSoon(context, 'Salary Structure'),
              ),
              _buildSettingsTile(
                Icons.calculate_outlined,
                'Tax Settings',
                'Configure tax rates and calculations',
                () => _showComingSoon(context, 'Tax Settings'),
              ),
              _buildSettingsTile(
                Icons.payment_outlined,
                'Payment Methods',
                'Manage payment methods and bank details',
                () => _showComingSoon(context, 'Payment Methods'),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _buildSettingsSection(
            'Notifications',
            [
              _buildSwitchTile(
                Icons.notifications_outlined,
                'Push Notifications',
                'Receive push notifications for important events',
                true,
                (value) => _showComingSoon(context, 'Push Notifications'),
              ),
              _buildSwitchTile(
                Icons.email_outlined,
                'Email Notifications',
                'Receive email updates for payroll and attendance',
                true,
                (value) => _showComingSoon(context, 'Email Notifications'),
              ),
              _buildSwitchTile(
                Icons.sms_outlined,
                'SMS Notifications',
                'Get SMS alerts for critical updates',
                false,
                (value) => _showComingSoon(context, 'SMS Notifications'),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _buildSettingsSection(
            'Data & Privacy',
            [
              _buildSettingsTile(
                Icons.backup_outlined,
                'Data Backup',
                'Backup your data to cloud storage',
                () => _showComingSoon(context, 'Data Backup'),
              ),
              _buildSettingsTile(
                Icons.privacy_tip_outlined,
                'Privacy Policy',
                'Read our privacy policy',
                () => _showComingSoon(context, 'Privacy Policy'),
              ),
              _buildSettingsTile(
                Icons.description_outlined,
                'Terms of Service',
                'Read terms and conditions',
                () => _showComingSoon(context, 'Terms of Service'),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _buildSettingsSection(
            'Support',
            [
              _buildSettingsTile(
                Icons.help_outline,
                'Help Center',
                'Get help and find answers to common questions',
                () => _showComingSoon(context, 'Help Center'),
              ),
              _buildSettingsTile(
                Icons.bug_report_outlined,
                'Report a Bug',
                'Report issues or bugs in the app',
                () => _showComingSoon(context, 'Report Bug'),
              ),
              _buildSettingsTile(
                Icons.feedback_outlined,
                'Send Feedback',
                'Share your feedback and suggestions',
                () => _showComingSoon(context, 'Send Feedback'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
        ),
        SizedBox(height: 12.h),
        Card(
          elevation: AppConstants.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Column(
            children: tiles,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.sp),
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Icon(
          icon,
          color: AppConstants.primaryColor,
          size: 24.sp,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14.sp,
          color: AppConstants.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppConstants.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.sp),
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Icon(
          icon,
          color: AppConstants.primaryColor,
          size: 24.sp,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14.sp,
          color: AppConstants.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppConstants.primaryColor,
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }
}