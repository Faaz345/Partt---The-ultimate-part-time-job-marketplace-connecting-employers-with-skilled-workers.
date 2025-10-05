import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../../core/services/chat_service.dart';

class WorkerApplicationsScreen extends StatefulWidget {
  const WorkerApplicationsScreen({super.key});

  @override
  State<WorkerApplicationsScreen> createState() => _WorkerApplicationsScreenState();
}

class _WorkerApplicationsScreenState extends State<WorkerApplicationsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'pending', 'shortlisted', 'accepted', 'rejected'];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'My Applications',
            style: TextStyle(
              fontFamily: AppConstants.fontFamily,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            'Please log in to view applications',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppConstants.textSecondary,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Applications',
          style: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppConstants.backgroundColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('workerId', isEqualTo: user.uid)
            .orderBy('appliedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final errorMessage = snapshot.error.toString();
            final isIndexBuilding = errorMessage.contains('index') || 
                                   errorMessage.contains('FAILED_PRECONDITION');
            
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isIndexBuilding ? Icons.hourglass_empty : Icons.error_outline,
                      size: 64.sp,
                      color: isIndexBuilding ? AppConstants.warningColor : AppConstants.errorColor,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      isIndexBuilding 
                          ? 'Setting Up Applications'
                          : 'Error Loading Applications',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                        fontFamily: AppConstants.fontFamily,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      isIndexBuilding
                          ? 'We\'re setting up the database for your applications. This usually takes 2-5 minutes. Please check back shortly!'
                          : 'Unable to load your applications. Please try again.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppConstants.textSecondary,
                        fontFamily: AppConstants.fontFamily,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isIndexBuilding) ...[
                      SizedBox(height: 24.h),
                      CircularProgressIndicator(
                        color: AppConstants.primaryColor,
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {});
                        },
                        icon: Icon(Icons.refresh),
                        label: Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppConstants.primaryColor,
              ),
            );
          }
          
          final applications = snapshot.data!.docs;
          
          return Column(
            children: [
              _buildFilterSection(),
              _buildStatsSection(applications),
              Expanded(child: _buildApplicationsList(applications)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            'Status:',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimary,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppConstants.primaryColor 
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        filter == 'All' ? filter : filter[0].toUpperCase() + filter.substring(1),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : AppConstants.textPrimary,
                          fontFamily: AppConstants.fontFamily,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(List<QueryDocumentSnapshot> allApplications) {
    final pendingCount = allApplications.where((app) => (app.data() as Map)['status'] == 'pending').length;
    final shortlistedCount = allApplications.where((app) => (app.data() as Map)['status'] == 'shortlisted').length;
    final acceptedCount = allApplications.where((app) => (app.data() as Map)['status'] == 'accepted').length;

    return Container(
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              allApplications.length.toString(),
              Icons.description_outlined,
              AppConstants.primaryColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'Pending',
              pendingCount.toString(),
              Icons.schedule,
              AppConstants.warningColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'Shortlisted',
              shortlistedCount.toString(),
              Icons.star_outline,
              AppConstants.secondaryColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'Accepted',
              acceptedCount.toString(),
              Icons.check_circle_outline,
              AppConstants.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 20.sp,
          ),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 10.sp,
                color: AppConstants.textSecondary,
                fontFamily: AppConstants.fontFamily,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsList(List<QueryDocumentSnapshot> allApplications) {
    final filteredApplications = _getFilteredApplications(allApplications);
    
    if (filteredApplications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'No applications found',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontFamily: AppConstants.fontFamily,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _selectedFilter == 'All' 
                  ? 'Start applying to jobs to see them here!'
                  : 'No $_selectedFilter applications at the moment',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
                fontFamily: AppConstants.fontFamily,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: filteredApplications.length,
      itemBuilder: (context, index) {
        final application = filteredApplications[index];
        return _buildApplicationCard(application);
      },
    );
  }

  Widget _buildApplicationCard(QueryDocumentSnapshot applicationDoc) {
    final application = applicationDoc.data() as Map<String, dynamic>;
    final status = application['status'] as String;
    final statusColor = _getStatusColor(status);
    final appliedAt = (application['appliedAt'] as Timestamp?)?.toDate();
    final timeAgo = appliedAt != null ? _getTimeAgo(appliedAt) : 'Unknown';
    
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () => _viewApplicationDetails(applicationDoc),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.work_outline,
                      color: AppConstants.primaryColor,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application['jobTitle'] ?? 'Job',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.textPrimary,
                            fontFamily: AppConstants.fontFamily,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          application['jobCompany'] ?? 'Company',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppConstants.primaryColor,
                            fontFamily: AppConstants.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      status[0].toUpperCase() + status.substring(1),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                        fontFamily: AppConstants.fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12.h),
              
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 16.sp, color: AppConstants.textSecondary),
                    SizedBox(width: 6.w),
                    Text(
                      'Applied $timeAgo',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppConstants.textSecondary,
                        fontFamily: AppConstants.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              
              if (status == 'shortlisted') ...[
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppConstants.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppConstants.secondaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, size: 16.sp, color: AppConstants.secondaryColor),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Great news! You\'ve been shortlisted. The employer is reviewing your application.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppConstants.secondaryColor,
                            fontFamily: AppConstants.fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              if (status == 'accepted') ...[
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppConstants.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppConstants.successColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.celebration, size: 16.sp, color: AppConstants.successColor),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Congratulations! Your application has been accepted. The employer will contact you soon.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppConstants.successColor,
                            fontFamily: AppConstants.fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openChat(application),
                    icon: Icon(Icons.chat_bubble, size: 18.sp),
                    label: Text('Chat with Employer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<QueryDocumentSnapshot> _getFilteredApplications(List<QueryDocumentSnapshot> applications) {
    if (_selectedFilter == 'All') {
      return applications;
    }
    return applications.where((app) => (app.data() as Map)['status'] == _selectedFilter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppConstants.warningColor;
      case 'shortlisted':
        return AppConstants.secondaryColor;
      case 'accepted':
        return AppConstants.successColor;
      case 'rejected':
        return AppConstants.errorColor;
      default:
        return Colors.grey;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'just now';
    }
  }

  void _viewApplicationDetails(QueryDocumentSnapshot applicationDoc) {
    final application = applicationDoc.data() as Map<String, dynamic>;
    final status = application['status'] as String;
    final statusColor = _getStatusColor(status);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(20.w),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Icon(
                Icons.work_outline,
                size: 48.sp,
                color: AppConstants.primaryColor,
              ),
              SizedBox(height: 16.h),
              Text(
                application['jobTitle'] ?? 'Job',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                  fontFamily: AppConstants.fontFamily,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                application['jobCompany'] ?? 'Company',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppConstants.primaryColor,
                  fontFamily: AppConstants.fontFamily,
                ),
              ),
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getStatusIcon(status),
                      color: statusColor,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Status: ${status[0].toUpperCase()}${status.substring(1)}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                        fontFamily: AppConstants.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Your Cover Letter',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                  fontFamily: AppConstants.fontFamily,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  application['coverLetter'] ?? 'No cover letter provided',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppConstants.textSecondary,
                    fontFamily: AppConstants.fontFamily,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'shortlisted':
        return Icons.star;
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Future<void> _openChat(Map<String, dynamic> application) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get worker data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final userData = userDoc.data();
      
      // Get job data to find manager info
      final jobDoc = await FirebaseFirestore.instance
          .collection('jobs')
          .doc(application['jobId'])
          .get();
      
      final jobData = jobDoc.data();
      
      if (jobData == null) {
        throw Exception('Job not found');
      }
      
      // Get manager data
      final managerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(jobData['managerId'])
          .get();
      
      final managerData = managerDoc.data();
      
      // Get or create conversation
      final chatService = ChatService();
      final conversation = await chatService.createOrGetConversation(
        user1Id: user.uid,
        user1Name: userData?['fullName'] ?? 'Worker',
        user1ProfileImage: userData?['profileImageUrl'],
        user2Id: jobData['managerId'],
        user2Name: managerData?['fullName'] ?? application['jobCompany'] ?? 'Manager',
        user2ProfileImage: managerData?['profileImageUrl'],
        relatedJobId: application['jobId'],
        relatedApplicationId: application['applicationId'],
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(conversation: conversation),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error opening chat: ${e.toString()}',
              style: TextStyle(fontFamily: AppConstants.fontFamily),
            ),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }
}
