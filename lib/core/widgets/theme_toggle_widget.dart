import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_constants.dart';
import '../providers/theme_provider.dart';

class ThemeToggleWidget extends ConsumerWidget {
  final bool showLabel;
  
  const ThemeToggleWidget({
    super.key,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDark = themeMode == ThemeMode.dark;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: isDark ? Colors.white : AppConstants.primaryColor,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            isDark ? 'Dark Mode' : 'Light Mode',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              fontFamily: AppConstants.fontFamily,
              color: isDark ? Colors.white : AppConstants.textPrimary,
            ),
          ),
          const Spacer(),
        ],
        Switch(
          value: isDark,
          onChanged: (value) => themeNotifier.toggleTheme(),
          activeColor: AppConstants.secondaryColor,
          activeTrackColor: AppConstants.secondaryColor.withValues(alpha: 0.3),
          inactiveThumbColor: Colors.grey[400],
          inactiveTrackColor: Colors.grey[300],
        ),
      ],
    );
  }
}

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDark = themeMode == ThemeMode.dark;
    
    return IconButton(
      onPressed: () => themeNotifier.toggleTheme(),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          key: ValueKey(isDark),
          color: isDark ? AppConstants.secondaryColor : AppConstants.primaryColor,
          size: 24.sp,
        ),
      ),
      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
    );
  }
}