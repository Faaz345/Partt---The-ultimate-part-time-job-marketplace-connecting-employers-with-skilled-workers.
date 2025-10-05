import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../chat/utils/chat_helper.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../../core/services/chat_service.dart';
import '../../../../core/helpers/notification_integration_helper.dart';

class ManagerApplicationsScreen extends StatefulWidget {
  const ManagerApplicationsScreen({super.key});

  @override
  State<ManagerApplicationsScreen> createState() => _ManagerApplicationsScreenState();
}

class _ManagerApplicationsScreenState extends State<ManagerApplicationsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'pending', 'shortlisted', 'accepted', 'rejected'];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Job Applications',
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
          'Job Applications',
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
            .where('managerId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48.sp,
                    color: AppConstants.errorColor,
                  ),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      'Error loading applications',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.errorColor,
                        fontFamily: AppConstants.fontFamily,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      '${snapshot.error}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppConstants.textSecondary,
                        fontFamily: AppConstants.fontFamily,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
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
          
          // Sort applications by appliedAt on client side
          final applications = snapshot.data!.docs.toList();
          applications.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = (aData['appliedAt'] as Timestamp?)?.toDate();
            final bTime = (bData['appliedAt'] as Timestamp?)?.toDate();
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime); // Descending order
          });
          
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
            'Filter:',
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
              Icons.people_outline,
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
                  ? 'Applications will appear here when workers apply'
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
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                    backgroundImage: application['workerProfileImageUrl'] != null 
                        ? NetworkImage(application['workerProfileImageUrl'])
                        : null,
                    child: application['workerProfileImageUrl'] == null 
                        ? Icon(Icons.person, size: 24.sp, color: AppConstants.primaryColor)
                        : null,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application['workerName'] ?? 'Unknown Worker',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.textPrimary,
                            fontFamily: AppConstants.fontFamily,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          application['jobTitle'] ?? 'Job',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppConstants.primaryColor,
                            fontFamily: AppConstants.fontFamily,
                          ),
                        ),
                        if (application['workerEmail'] != null) ...[
                          SizedBox(height: 2.h),
                          Text(
                            application['workerEmail'],
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppConstants.textSecondary,
                              fontFamily: AppConstants.fontFamily,
                            ),
                          ),
                        ],
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
              
              Text(
                'Cover Letter:',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimary,
                  fontFamily: AppConstants.fontFamily,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                application['coverLetter'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppConstants.textSecondary,
                  fontFamily: AppConstants.fontFamily,
                  height: 1.4,
                ),
              ),
              
              SizedBox(height: 12.h),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Applied $timeAgo',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      fontFamily: AppConstants.fontFamily,
                    ),
                  ),
                  if (status == 'pending')
                    Row(
                      children: [
                        _buildQuickActionButton(
                          'Shortlist',
                          Icons.star,
                          AppConstants.secondaryColor,
                          () => _updateApplicationStatus(applicationDoc.id, 'shortlisted'),
                        ),
                        SizedBox(width: 8.w),
                        _buildQuickActionButton(
                          'Reject',
                          Icons.close,
                          AppConstants.errorColor,
                          () => _updateApplicationStatus(applicationDoc.id, 'rejected'),
                        ),
                      ],
                    ),
                  if (status == 'accepted' || status == 'shortlisted')
                    _buildQuickActionButton(
                      'Chat',
                      Icons.chat_bubble,
                      AppConstants.primaryColor,
                      () => _openChat(application),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14.sp, color: color),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: color,
                fontWeight: FontWeight.w500,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
          ],
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
      return 'Just now';
    }
  }

  Future<void> _updateApplicationStatus(String applicationId, String newStatus) async {
    try {
      // Get application data first
      final applicationDoc = await FirebaseFirestore.instance
          .collection('applications')
          .doc(applicationId)
          .get();
      
      final application = applicationDoc.data();
      
      // Update status
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(applicationId)
          .update({
        'status': newStatus,
        'statusUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Send notification to worker about status change
      if (application != null && newStatus != 'pending') {
        try {
          await NotificationIntegrationHelper.notifyWorkerAboutApplicationStatus(
            workerId: application['workerId'],
            applicationId: applicationId,
            jobTitle: application['jobTitle'] ?? 'Job',
            businessName: application['jobCompany'] ?? 'Company',
            status: newStatus,
          );
        } catch (notifError) {
          print('Error sending notification: $notifError');
          // Continue even if notification fails
        }
      }
      
      // Activate chat if accepted
      if (newStatus == 'accepted' && application != null) {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            // Get manager data
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
            
            final userData = userDoc.data();
            
            await ChatHelper.activateChatForAcceptedApplication(
              managerId: user.uid,
              managerName: userData?['fullName'] ?? 'Manager',
              managerProfileImage: userData?['profileImageUrl'],
              workerId: application['workerId'],
              workerName: application['workerName'] ?? 'Worker',
              workerProfileImage: application['workerProfileImageUrl'],
              jobId: application['jobId'] ?? '',
              applicationId: applicationId,
              jobTitle: application['jobTitle'],
            );
          }
        } catch (chatError) {
          print('Error activating chat: $chatError');
          // Continue even if chat activation fails
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'accepted' 
                  ? 'Application accepted! Chat activated.'
                  : 'Application ${newStatus == 'shortlisted' ? 'shortlisted' : 'rejected'} successfully',
              style: TextStyle(fontFamily: AppConstants.fontFamily),
            ),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error updating application: ${e.toString()}',
              style: TextStyle(fontFamily: AppConstants.fontFamily),
            ),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  void _viewApplicationDetails(QueryDocumentSnapshot applicationDoc) {
    final application = applicationDoc.data() as Map<String, dynamic>;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
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
              CircleAvatar(
                radius: 40.r,
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                backgroundImage: application['workerProfileImageUrl'] != null 
                    ? NetworkImage(application['workerProfileImageUrl'])
                    : null,
                child: application['workerProfileImageUrl'] == null 
                    ? Icon(Icons.person, size: 40.sp, color: AppConstants.primaryColor)
                    : null,
              ),
              SizedBox(height: 16.h),
              Text(
                application['workerName'] ?? 'Unknown Worker',
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
                application['jobTitle'] ?? 'Job',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppConstants.primaryColor,
                  fontFamily: AppConstants.fontFamily,
                ),
              ),
              SizedBox(height: 24.h),
              _buildDetailSection('Contact Information', [
                _buildDetailRow(Icons.email, application['workerEmail'] ?? 'N/A'),
                if (application['workerPhone'] != null && application['workerPhone'].toString().isNotEmpty)
                  _buildDetailRow(Icons.phone, application['workerPhone']),
              ]),
              SizedBox(height: 16.h),
              _buildDetailSection('Cover Letter', [
                Text(
                  application['coverLetter'] ?? 'No cover letter provided',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppConstants.textSecondary,
                    fontFamily: AppConstants.fontFamily,
                    height: 1.5,
                  ),
                ),
              ]),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _updateApplicationStatus(applicationDoc.id, 'shortlisted');
                      },
                      icon: Icon(Icons.star),
                      label: Text('Shortlist'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _updateApplicationStatus(applicationDoc.id, 'accepted');
                      },
                      icon: Icon(Icons.check_circle),
                      label: Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.successColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateApplicationStatus(applicationDoc.id, 'rejected');
                  },
                  icon: Icon(Icons.close),
                  label: Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.errorColor,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    side: BorderSide(color: AppConstants.errorColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
            fontFamily: AppConstants.fontFamily,
          ),
        ),
        SizedBox(height: 8.h),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: AppConstants.primaryColor),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppConstants.textSecondary,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openChat(Map<String, dynamic> application) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get manager data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final userData = userDoc.data();
      
      // Get or create conversation
      final chatService = ChatService();
      final conversation = await chatService.createOrGetConversation(
        user1Id: user.uid,
        user1Name: userData?['fullName'] ?? 'Manager',
        user1ProfileImage: userData?['profileImageUrl'],
        user2Id: application['workerId'],
        user2Name: application['workerName'] ?? 'Worker',
        user2ProfileImage: application['workerProfileImageUrl'],
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
