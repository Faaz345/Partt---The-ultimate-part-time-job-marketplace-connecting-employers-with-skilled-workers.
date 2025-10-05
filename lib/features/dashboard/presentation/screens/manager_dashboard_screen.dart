import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/widgets/banner_ad_widget.dart';
import '../../../jobs/presentation/screens/job_posting_screen.dart';
import '../../../jobs/presentation/screens/manage_jobs_screen.dart';
import '../../../jobs/presentation/screens/manager_applications_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();
  
  final List<Widget> _screens = [
    const DashboardHomeScreen(),
    const ManagerApplicationsScreen(),
    const ManageJobsScreen(),
    const JobPostingScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: StreamBuilder<QuerySnapshot>(
        stream: user != null
            ? FirebaseFirestore.instance
                .collection('applications')
                .where('managerId', isEqualTo: user.uid)
                .where('status', isEqualTo: 'pending')
                .snapshots()
            : null,
        builder: (context, snapshot) {
          final pendingCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
          
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: AppConstants.primaryColor,
            unselectedItemColor: AppConstants.textSecondary,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.people_outline),
                    if (pendingCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16.w,
                            minHeight: 16.h,
                          ),
                          child: Text(
                            pendingCount > 99 ? '99+' : pendingCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Applications',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.work),
                label: 'Jobs',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.add_business),
                label: 'Post Job',
              ),
            ],
          );
        },
      ),
    );
  }
}

// Dashboard Home Screen
class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({Key? key}) : super(key: key);
  
  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  final _authService = AuthService();
  int _activeJobsCount = 0;
  int _applicationsCount = 0;
  int _hiredCount = 0;
  int _pendingReviewCount = 0;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadManagerStats();
  }
  
  Future<void> _loadManagerStats() async {
    try {
      setState(() => _isLoading = true);
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      // Count active jobs
      final activeJobsSnapshot = await FirebaseFirestore.instance
          .collection('jobs')
          .where('managerId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'open')
          .get();
      
      // Count all applications for manager's jobs
      final managerJobIds = activeJobsSnapshot.docs.map((doc) => doc.id).toList();
      
      int totalApplications = 0;
      int pending = 0;
      int hired = 0;
      
      if (managerJobIds.isNotEmpty) {
        final applicationsSnapshot = await FirebaseFirestore.instance
            .collection('applications')
            .where('jobId', whereIn: managerJobIds.take(10).toList()) // Firestore limit
            .get();
        
        totalApplications = applicationsSnapshot.docs.length;
        pending = applicationsSnapshot.docs
            .where((doc) => doc.data()['status'] == 'pending')
            .length;
        hired = applicationsSnapshot.docs
            .where((doc) => doc.data()['status'] == 'accepted')
            .length;
      }
      
      setState(() {
        _activeJobsCount = activeJobsSnapshot.docs.length;
        _applicationsCount = totalApplications;
        _pendingReviewCount = pending;
        _hiredCount = hired;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading manager stats: $e');
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppConstants.primaryColor,
                AppConstants.primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.business_center,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
        ),
        title: Text(
          'Manager Dashboard',
          style: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          // Notification Bell Icon
          StreamBuilder<int>(
            stream: NotificationService().getUnreadNotificationsCount(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              
              return Container(
                margin: EdgeInsets.only(right: 8.w),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 18.w,
                            minHeight: 18.h,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          // Profile Icon
          Container(
            margin: EdgeInsets.only(right: 8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.person),
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              SizedBox(height: 24.h),
              // Banner Ad
              const Center(child: BannerAdWidget()),
              SizedBox(height: 24.h),
              _buildStatsCards(),
              SizedBox(height: 24.h),
              _buildQuickActions(),
              SizedBox(height: 16.h),
              // Bottom Banner Ad
              const Center(child: BannerAdWidget()),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _refreshData() async {
    await _loadManagerStats();
  }
  
  Widget _buildWelcomeCard() {
    final user = _authService.currentUser;
    final userName = user?.displayName?.split(' ').first ?? 'Manager';
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor,
            AppConstants.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, $userName!',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: AppConstants.fontFamily,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Manage your jobs and connect with talent',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white.withOpacity(0.9),
                        fontFamily: AppConstants.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.business_center,
                  color: Colors.white,
                  size: 32.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Overview',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
            fontFamily: AppConstants.fontFamily,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Active Jobs',
                _activeJobsCount.toString(),
                Icons.work,
                AppConstants.primaryColor,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                'Applications',
                _applicationsCount.toString(),
                Icons.person_search,
                AppConstants.secondaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Hired This Month',
                _hiredCount.toString(),
                Icons.check_circle,
                AppConstants.successColor,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                'Pending Review',
                _pendingReviewCount.toString(),
                Icons.pending_actions,
                AppConstants.warningColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              size: 24.sp,
              color: color,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppConstants.textSecondary,
              fontFamily: AppConstants.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
            fontFamily: AppConstants.fontFamily,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              'Post New Job',
              Icons.add_business,
              AppConstants.primaryColor,
              () => _navigateToJobPosting(),
            ),
            _buildActionCard(
              'Manage Jobs',
              Icons.work_outline,
              AppConstants.secondaryColor,
              () => _navigateToManageJobs(),
            ),
            _buildActionCard(
              'Applications',
              Icons.people_alt,
              AppConstants.successColor,
              () => _showComingSoon('Applications'),
            ),
            _buildActionCard(
              'Analytics',
              Icons.analytics,
              AppConstants.warningColor,
              () => _showComingSoon('Analytics'),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                size: 22.sp,
                color: color,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppConstants.textPrimary,
                fontFamily: AppConstants.fontFamily,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToJobPosting() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const JobPostingScreen(),
      ),
    );
  }
  
  void _navigateToManageJobs() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ManageJobsScreen(),
      ),
    );
  }
  
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature feature coming soon!',
          style: TextStyle(fontFamily: AppConstants.fontFamily),
        ),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }
}
