import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/job_model.dart';

class ManageJobsScreen extends StatefulWidget {
  const ManageJobsScreen({super.key});

  @override
  State<ManageJobsScreen> createState() => _ManageJobsScreenState();
}

class _ManageJobsScreenState extends State<ManageJobsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'open', 'closed', 'draft'];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Manage Jobs',
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
            'Please log in to manage jobs',
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
          'Manage Jobs',
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
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            tooltip: 'Search Jobs',
          ),
        ],
      ),
      backgroundColor: AppConstants.backgroundColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where('managerId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error loading jobs: ${snapshot.error}');
            return Center(
              child: Text(
                'Error loading jobs: ${snapshot.error}',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppConstants.errorColor,
                  fontFamily: AppConstants.fontFamily,
                ),
                textAlign: TextAlign.center,
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
          
          final jobs = snapshot.data!.docs
              .map((doc) => JobModel.fromFirestore(doc))
              .toList();
          
          return Column(
            children: [
              _buildFilterSection(),
              _buildStatsSection(jobs),
              Expanded(child: _buildJobsList(jobs)),
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
                        filter,
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

  Widget _buildStatsSection(List<JobModel> allJobs) {
    final activeJobs = allJobs.where((job) => job.status == 'open').length;
    final totalApplicants = allJobs.fold<int>(0, (sum, job) => sum + job.currentApplicants);

    return Container(
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Jobs',
              allJobs.length.toString(),
              Icons.work_outline,
              AppConstants.primaryColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'Active Jobs',
              activeJobs.toString(),
              Icons.trending_up,
              AppConstants.secondaryColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'Applicants',
              totalApplicants.toString(),
              Icons.people_outline,
              AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
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

  Widget _buildJobsList(List<JobModel> allJobs) {
    final filteredJobs = _getFilteredJobs(allJobs);
    
    if (filteredJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'No jobs found',
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
                  ? 'Start by posting your first job!'
                  : 'No $_selectedFilter jobs at the moment',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
                fontFamily: AppConstants.fontFamily,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: filteredJobs.length,
      itemBuilder: (context, index) {
        final job = filteredJobs[index];
        return _buildJobCard(job);
      },
    );
  }

  Widget _buildJobCard(JobModel job) {
    final statusColor = _getStatusColor(job.status);
    final statusDisplay = job.status == 'open' ? 'Active' : job.status == 'closed' ? 'Closed' : 'Draft';
    final isRemote = job.location.toLowerCase() == 'remote';
    final timeAgo = _getTimeAgo(job.createdAt);
    
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.textPrimary,
                          fontFamily: AppConstants.fontFamily,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        job.category,
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
                    statusDisplay,
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
            
            Row(
              children: [
                Icon(
                  isRemote ? Icons.home : Icons.location_on,
                  size: 16.sp,
                  color: AppConstants.textSecondary,
                ),
                SizedBox(width: 4.w),
                Text(
                  job.location,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppConstants.textSecondary,
                    fontFamily: AppConstants.fontFamily,
                  ),
                ),
                SizedBox(width: 16.w),
                Icon(
                  Icons.attach_money,
                  size: 16.sp,
                  color: AppConstants.textSecondary,
                ),
                SizedBox(width: 4.w),
                Text(
                  job.formattedSalary,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppConstants.textSecondary,
                    fontFamily: AppConstants.fontFamily,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '${job.currentApplicants} applicants',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppConstants.secondaryColor,
                            fontFamily: AppConstants.fontFamily,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          'Posted $timeAgo',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                            fontFamily: AppConstants.fontFamily,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _viewJobDetails(job),
                      icon: Icon(
                        Icons.visibility,
                        color: AppConstants.primaryColor,
                        size: 20.sp,
                      ),
                      tooltip: 'View Details',
                    ),
                    IconButton(
                      onPressed: () => _editJob(job),
                      icon: Icon(
                        Icons.edit,
                        color: AppConstants.secondaryColor,
                        size: 20.sp,
                      ),
                      tooltip: 'Edit Job',
                    ),
                    IconButton(
                      onPressed: () => _deleteJob(job),
                      icon: Icon(
                        Icons.delete,
                        color: AppConstants.errorColor,
                        size: 20.sp,
                      ),
                      tooltip: 'Delete Job',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<JobModel> _getFilteredJobs(List<JobModel> jobs) {
    if (_selectedFilter == 'All') {
      return jobs;
    }
    return jobs.where((job) => job.status == _selectedFilter).toList();
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return AppConstants.successColor;
      case 'closed':
        return AppConstants.errorColor;
      case 'draft':
        return AppConstants.warningColor;
      default:
        return Colors.grey;
    }
  }

  void _viewJobDetails(JobModel job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          job.title,
          style: TextStyle(
            fontFamily: AppConstants.fontFamily,
            color: AppConstants.primaryColor,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category: ${job.category}'),
              SizedBox(height: 8.h),
              Text('Location: ${job.location}'),
              SizedBox(height: 8.h),
              Text('Salary: ${job.formattedSalary}'),
              SizedBox(height: 8.h),
              Text('Applicants: ${job.currentApplicants}/${job.maxApplicants}'),
              SizedBox(height: 8.h),
              Text('Status: ${job.status}'),
              SizedBox(height: 8.h),
              Text('Working Hours: ${job.workingHours}'),
              SizedBox(height: 8.h),
              Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(job.description),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editJob(JobModel job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit functionality coming soon!',
          style: TextStyle(fontFamily: AppConstants.fontFamily),
        ),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }

  void _deleteJob(JobModel job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Job',
          style: TextStyle(
            fontFamily: AppConstants.fontFamily,
            color: AppConstants.errorColor,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${job.title}"? This action cannot be undone.',
          style: TextStyle(fontFamily: AppConstants.fontFamily),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppConstants.textSecondary,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(
                color: AppConstants.errorColor,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('jobs')
            .doc(job.id)
            .delete();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Job deleted successfully',
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
                'Error deleting job: ${e.toString()}',
                style: TextStyle(fontFamily: AppConstants.fontFamily),
              ),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      }
    }
  }
}