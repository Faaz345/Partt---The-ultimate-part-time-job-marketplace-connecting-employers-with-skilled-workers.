import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Partt';
  static const String appVersion = '1.0.0';
  
  // Assets
  static const String logoMain = 'assets/images/partt_main_logo.png';
  static const String logoApp = 'assets/images/partt_app_logo.png';
  static const String logoIcon = 'assets/images/partt_icon.png';
  
  // Custom Font
  static const String fontFamily = 'ParttFont';

  // Brand Colors - Modern Scheme
  static const Color primaryColor = Color(0xFF2C81C5);  // Steel Blue: #2C81C5
  static const Color secondaryColor = Color(0xFFB2D528); // Yellow-Green: #B2D528
  static const Color accentColor = Color(0xFF2C81C5);    // Using primary as accent
  static const Color darkModeBlack = Color(0xFF39414A);  // Charcoal: #39414A
  
  // Surface and background colors
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Colors.white;
  static const Color darkBackground = Color(0xFF39414A);
  static const Color darkSurface = Color(0xFF4A5159);
  
  // Status colors
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color successColor = Color(0xFF38A169);
  static const Color warningColor = Color(0xFFD69E2E);
  
  // Text colors
  static const Color textPrimary = Color(0xFF39414A);     // Using dark brand color (Charcoal)
  static const Color textSecondary = Color(0xFF6C757D);   // Softer gray
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSecondary = Color(0xFF39414A);
  static const Color textOnDark = Colors.white;

  // Text Styles with Custom Font
  static const TextStyle headingStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle titleStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle captionStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  // Dimensions
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Routes
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String profileSetupRoute = '/profile-setup';
  static const String workerDashboardRoute = '/worker-dashboard';
  static const String managerDashboardRoute = '/manager-dashboard';
  static const String jobDetailsRoute = '/job-details';
  static const String settingsRoute = '/settings';
  static const String notificationsRoute = '/notifications';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String jobsCollection = 'jobs';
  static const String applicationsCollection = 'applications';
  static const String notificationsCollection = 'notifications';
  static const String chatsCollection = 'chats';

  // User Roles
  static const String workerRole = 'worker';
  static const String managerRole = 'manager';

  // Job Categories
  static const List<String> jobCategories = [
    'Retail',
    'Food & Beverage',
    'Customer Service',
    'Warehouse',
    'Cleaning',
    'Security',
    'Delivery',
    'Event Staff',
    'Administrative',
    'Other',
  ];

  // Education Levels
  static const List<String> educationLevels = [
    'High School',
    'Some College',
    'Associate Degree',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD',
    'Vocational Training',
    'Other',
  ];

  // Experience Levels
  static const List<String> experienceLevels = [
    'No Experience',
    '0-1 years',
    '1-3 years',
    '3-5 years',
    '5-10 years',
    '10+ years',
  ];

  // Gender Options
  static const List<String> genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
  ];

  // Job Status
  static const String jobStatusOpen = 'open';
  static const String jobStatusClosed = 'closed';
  static const String jobStatusDraft = 'draft';

  // Application Status
  static const String applicationStatusPending = 'pending';
  static const String applicationStatusShortlisted = 'shortlisted';
  static const String applicationStatusAccepted = 'accepted';
  static const String applicationStatusRejected = 'rejected';

  // Notification Types
  static const String notificationTypeJobUpdate = 'job_update';
  static const String notificationTypeApplication = 'application';
  static const String notificationTypeMessage = 'message';
  static const String notificationTypeSystem = 'system';

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorAuth = 'Authentication failed. Please try again.';
  static const String errorPermission = 'Permission denied. Please grant required permissions.';
  static const String errorLocation = 'Unable to get your location. Please enable location services.';
  static const String errorCamera = 'Unable to access camera. Please check permissions.';

  // Success Messages
  static const String successProfileUpdated = 'Profile updated successfully!';
  static const String successJobPosted = 'Job posted successfully!';
  static const String successApplicationSubmitted = 'Application submitted successfully!';
  static const String successLogout = 'Logged out successfully!';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxAboutLength = 500;
  static const int maxJobTitleLength = 100;
  static const int maxJobDescriptionLength = 1000;

  // Location
  static const double defaultLocationRadius = 25.0; // km
  static const double maxLocationRadius = 100.0; // km
}