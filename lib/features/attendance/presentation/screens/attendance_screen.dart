import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: AppConstants.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today', icon: Icon(Icons.today)),
            Tab(text: 'This Week', icon: Icon(Icons.date_range)),
            Tab(text: 'Reports', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TodayAttendanceTab(),
          WeeklyAttendanceTab(),
          AttendanceReportsTab(),
        ],
      ),
    );
  }
}

// Today's Attendance Tab
class TodayAttendanceTab extends StatefulWidget {
  const TodayAttendanceTab({Key? key}) : super(key: key);

  @override
  State<TodayAttendanceTab> createState() => _TodayAttendanceTabState();
}

class _TodayAttendanceTabState extends State<TodayAttendanceTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTodayStatsCards(),
          SizedBox(height: 24.h),
          Text(
            'Employee Status',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: _buildEmployeeAttendanceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Present',
            '22',
            Icons.check_circle,
            AppConstants.successColor,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            'Late',
            '3',
            Icons.schedule,
            AppConstants.warningColor,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            'Absent',
            '2',
            Icons.cancel,
            AppConstants.errorColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: color,
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeAttendanceList() {
    // Mock data
    final employees = [
      {'name': 'John Smith', 'checkIn': '09:00', 'status': 'Present', 'color': AppConstants.successColor},
      {'name': 'Sarah Johnson', 'checkIn': '09:15', 'status': 'Late', 'color': AppConstants.warningColor},
      {'name': 'Michael Brown', 'checkIn': '08:45', 'status': 'Present', 'color': AppConstants.successColor},
      {'name': 'Emma Davis', 'checkIn': '--', 'status': 'Absent', 'color': AppConstants.errorColor},
    ];

    return ListView.builder(
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (employee['color'] as Color).withOpacity(0.2),
              child: Text(
                employee['name'].toString().split(' ').map((e) => e[0]).join('').toUpperCase(),
                style: TextStyle(
                  color: employee['color'] as Color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              employee['name'] as String,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
            subtitle: Text(
              'Check-in: ${employee['checkIn']}',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppConstants.textSecondary,
              ),
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: (employee['color'] as Color).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                employee['status'] as String,
                style: TextStyle(
                  color: employee['color'] as Color,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Weekly Attendance Tab
class WeeklyAttendanceTab extends StatelessWidget {
  const WeeklyAttendanceTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_view_week,
              size: 64.sp,
              color: AppConstants.primaryColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'Weekly Attendance View',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Weekly attendance tracking will be implemented in the next phase.',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Attendance Reports Tab
class AttendanceReportsTab extends StatelessWidget {
  const AttendanceReportsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.analytics,
              size: 64.sp,
              color: AppConstants.primaryColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'Attendance Reports',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Detailed attendance reports and analytics will be implemented in the next phase.',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}