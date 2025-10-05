import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payroll'),
        backgroundColor: AppConstants.primaryColor,
        actions: [
          IconButton(
            onPressed: () => _showComingSoon(context, 'Generate Reports'),
            icon: const Icon(Icons.file_download),
            tooltip: 'Generate Reports',
          ),
          IconButton(
            onPressed: () => _showComingSoon(context, 'Settings'),
            icon: const Icon(Icons.settings),
            tooltip: 'Payroll Settings',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPayrollSummaryCard(),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Payrolls',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => _showComingSoon(context, 'View All'),
                  child: const Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: _buildPayrollList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showComingSoon(context, 'Process Payroll'),
        backgroundColor: AppConstants.primaryColor,
        label: const Text('Process Payroll'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPayrollSummaryCard() {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryColor,
              AppConstants.primaryColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(20.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'March 2024 Summary',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Gross Pay',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '\$128,450',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Net Pay',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '\$109,183',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _buildMiniStat('Employees', '24', Colors.white.withOpacity(0.9)),
                SizedBox(width: 24.w),
                _buildMiniStat('Processed', '19', Colors.white.withOpacity(0.9)),
                SizedBox(width: 24.w),
                _buildMiniStat('Pending', '5', Colors.white.withOpacity(0.9)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: textColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPayrollList() {
    // Mock data
    final payrolls = [
      {
        'employee': 'John Smith',
        'period': 'March 2024',
        'grossPay': 4500.0,
        'netPay': 3825.0,
        'status': 'Processed',
        'statusColor': AppConstants.successColor,
        'date': '2024-03-31',
      },
      {
        'employee': 'Sarah Johnson',
        'period': 'March 2024',
        'grossPay': 2600.0,
        'netPay': 2210.0,
        'status': 'Processed',
        'statusColor': AppConstants.successColor,
        'date': '2024-03-31',
      },
      {
        'employee': 'Michael Brown',
        'period': 'March 2024',
        'grossPay': 5200.0,
        'netPay': 4420.0,
        'status': 'Pending',
        'statusColor': AppConstants.warningColor,
        'date': '2024-03-31',
      },
      {
        'employee': 'Emma Davis',
        'period': 'March 2024',
        'grossPay': 3800.0,
        'netPay': 3230.0,
        'status': 'Draft',
        'statusColor': AppConstants.textSecondary,
        'date': '2024-03-31',
      },
    ];

    return ListView.builder(
      itemCount: payrolls.length,
      itemBuilder: (context, index) {
        final payroll = payrolls[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        payroll['employee'] as String,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: (payroll['statusColor'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        payroll['status'] as String,
                        style: TextStyle(
                          color: payroll['statusColor'] as Color,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  payroll['period'] as String,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppConstants.textSecondary,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildPayrollDetailItem(
                        'Gross Pay',
                        '\$${(payroll['grossPay'] as double).toStringAsFixed(2)}',
                      ),
                    ),
                    Expanded(
                      child: _buildPayrollDetailItem(
                        'Net Pay',
                        '\$${(payroll['netPay'] as double).toStringAsFixed(2)}',
                      ),
                    ),
                    Expanded(
                      child: _buildPayrollDetailItem(
                        'Date',
                        payroll['date'] as String,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showComingSoon(context as BuildContext, 'View Details'),
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('View'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showComingSoon(context as BuildContext, 'Download Payslip'),
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: const Text('Download'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPayrollDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppConstants.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimary,
          ),
        ),
      ],
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