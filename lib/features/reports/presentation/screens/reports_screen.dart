import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics Dashboard',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 1.2,
                children: [
                  _buildReportCard(
                    'Attendance Report',
                    'Track employee attendance patterns',
                    Icons.access_time,
                    AppConstants.primaryColor,
                    () => _showComingSoon(context, 'Attendance Report'),
                  ),
                  _buildReportCard(
                    'Payroll Summary',
                    'Monthly payroll breakdown and analysis',
                    Icons.attach_money,
                    AppConstants.successColor,
                    () => _showComingSoon(context, 'Payroll Summary'),
                  ),
                  _buildReportCard(
                    'Employee Performance',
                    'Performance metrics and reviews',
                    Icons.trending_up,
                    AppConstants.warningColor,
                    () => _showComingSoon(context, 'Employee Performance'),
                  ),
                  _buildReportCard(
                    'Department Analytics',
                    'Department-wise performance analysis',
                    Icons.business,
                    AppConstants.errorColor,
                    () => _showComingSoon(context, 'Department Analytics'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12.sp),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Icon(
                  icon,
                  size: 32.sp,
                  color: color,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppConstants.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
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