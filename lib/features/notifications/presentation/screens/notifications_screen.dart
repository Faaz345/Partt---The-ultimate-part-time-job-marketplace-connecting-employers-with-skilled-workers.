import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: Text(
          'Notifications',
          style: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'mark_all_read') {
                _markAllAsRead();
              } else if (value == 'delete_all') {
                _showDeleteAllDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all, size: 20),
                    SizedBox(width: 12),
                    Text('Mark all as read'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete all', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontSize: 13.sp,
          ),
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Jobs'),
            Tab(text: 'Messages'),
            Tab(text: 'System'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllNotifications(),
          _buildJobNotifications(),
          _buildChatNotifications(),
          _buildSystemNotifications(),
        ],
      ),
    );
  }

  Widget _buildAllNotifications() {
    return StreamBuilder<List<NotificationModel>>(
      stream: _notificationService.getUserNotificationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AppConstants.primaryColor,
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorWidget('Error loading notifications');
        }

        final notifications = snapshot.data ?? [];

        if (notifications.isEmpty) {
          return _buildEmptyWidget(
            icon: Icons.notifications_none,
            message: 'No notifications yet',
            subtitle: 'You\'ll see notifications here when you get them',
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return _buildNotificationItem(notifications[index]);
          },
        );
      },
    );
  }

  Widget _buildJobNotifications() {
    return StreamBuilder<List<NotificationModel>>(
      stream: _notificationService.getUserNotificationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AppConstants.primaryColor,
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorWidget('Error loading job notifications');
        }

        final allNotifications = snapshot.data ?? [];
        final jobNotifications = allNotifications.where((n) => n.isJobRelated).toList();

        if (jobNotifications.isEmpty) {
          return _buildEmptyWidget(
            icon: Icons.work_outline,
            message: 'No job notifications',
            subtitle: 'Job-related notifications will appear here',
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: jobNotifications.length,
          itemBuilder: (context, index) {
            return _buildNotificationItem(jobNotifications[index]);
          },
        );
      },
    );
  }

  Widget _buildChatNotifications() {
    return StreamBuilder<List<NotificationModel>>(
      stream: _notificationService.getUserNotificationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AppConstants.primaryColor,
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorWidget('Error loading message notifications');
        }

        final allNotifications = snapshot.data ?? [];
        final chatNotifications = allNotifications.where((n) => n.isChatRelated).toList();

        if (chatNotifications.isEmpty) {
          return _buildEmptyWidget(
            icon: Icons.chat_bubble_outline,
            message: 'No message notifications',
            subtitle: 'New messages will appear here',
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: chatNotifications.length,
          itemBuilder: (context, index) {
            return _buildNotificationItem(chatNotifications[index]);
          },
        );
      },
    );
  }

  Widget _buildSystemNotifications() {
    return StreamBuilder<List<NotificationModel>>(
      stream: _notificationService.getUserNotificationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AppConstants.primaryColor,
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorWidget('Error loading system notifications');
        }

        final allNotifications = snapshot.data ?? [];
        final systemNotifications = allNotifications.where((n) => n.isSystemNotification).toList();

        if (systemNotifications.isEmpty) {
          return _buildEmptyWidget(
            icon: Icons.info_outline,
            message: 'No system notifications',
            subtitle: 'System updates will appear here',
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: systemNotifications.length,
          itemBuilder: (context, index) {
            return _buildNotificationItem(systemNotifications[index]);
          },
        );
      },
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _notificationService.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // TODO: Implement undo functionality
              },
            ),
          ),
        );
      },
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.white
                : AppConstants.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: notification.isRead
                  ? Colors.grey.shade300
                  : AppConstants.primaryColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                              color: AppConstants.textPrimary,
                              fontFamily: AppConstants.fontFamily,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppConstants.textSecondary,
                        fontFamily: AppConstants.fontFamily,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12.sp,
                          color: AppConstants.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          notification.formattedTime,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppConstants.textSecondary,
                            fontFamily: AppConstants.fontFamily,
                          ),
                        ),
                        if (notification.isHighPriority) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              notification.priority.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppConstants.fontFamily,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget({
    required IconData icon,
    required String message,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppConstants.textSecondary,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppConstants.textSecondary.withOpacity(0.7),
              fontFamily: AppConstants.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppConstants.textSecondary,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'job_posted':
        return Icons.work;
      case 'job_applied':
        return Icons.person_add;
      case 'application_status':
        return Icons.assignment_turned_in;
      case 'job_reminder':
        return Icons.alarm;
      case 'chat':
        return Icons.chat_bubble;
      case 'system':
      default:
        return Icons.info;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'job_posted':
        return AppConstants.primaryColor;
      case 'job_applied':
        return AppConstants.secondaryColor;
      case 'application_status':
        return AppConstants.successColor;
      case 'job_reminder':
        return AppConstants.warningColor;
      case 'chat':
        return Colors.blue;
      case 'system':
      default:
        return Colors.grey;
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read
    if (!notification.isRead) {
      _notificationService.markAsRead(notification.id);
    }

    // Handle navigation based on notification type
    // TODO: Implement navigation to specific screens based on actionUrl or type
    if (notification.actionUrl != null) {
      print('Navigate to: ${notification.actionUrl}');
      // Navigator.pushNamed(context, notification.actionUrl!);
    }
  }

  Future<void> _markAllAsRead() async {
    await _notificationService.markAllAsRead();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
        ),
      );
    }
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Notifications'),
        content: const Text('Are you sure you want to delete all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _notificationService.deleteAllNotifications();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications deleted'),
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
