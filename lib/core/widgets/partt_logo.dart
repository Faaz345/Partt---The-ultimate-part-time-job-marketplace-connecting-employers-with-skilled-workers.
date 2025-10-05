import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_constants.dart';

class ParttLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final bool showText;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final LogoType type;

  const ParttLogo({
    super.key,
    this.width,
    this.height,
    this.showText = false,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.type = LogoType.main,
  });

  const ParttLogo.small({
    super.key,
    this.showText = false,
    this.textColor,
    this.type = LogoType.main,
  }) : width = 24,
       height = 24,
       fontSize = 12,
       fontWeight = FontWeight.w600;

  const ParttLogo.medium({
    super.key,
    this.showText = false,
    this.textColor,
    this.type = LogoType.main,
  }) : width = 40,
       height = 40,
       fontSize = 16,
       fontWeight = FontWeight.w600;

  const ParttLogo.large({
    super.key,
    this.showText = true,
    this.textColor,
    this.type = LogoType.main,
  }) : width = 80,
       height = 80,
       fontSize = 24,
       fontWeight = FontWeight.bold;

  const ParttLogo.appBar({
    super.key,
    this.showText = false,
    this.textColor = Colors.white,
    this.type = LogoType.main,
  }) : width = 32,
       height = 32,
       fontSize = 14,
       fontWeight = FontWeight.w600;

  @override
  Widget build(BuildContext context) {
    final logoAsset = _getLogoAsset();
    final effectiveWidth = width?.w ?? 40.w;
    final effectiveHeight = height?.h ?? 40.h;

    if (showText) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogo(logoAsset, effectiveWidth, effectiveHeight),
          if (showText) ...[
            SizedBox(height: 8.h),
            Text(
              'Partt',
              style: TextStyle(
                fontSize: fontSize?.sp ?? 16.sp,
                fontWeight: fontWeight ?? FontWeight.w600,
                color: textColor ?? AppConstants.primaryColor,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
          ],
        ],
      );
    }

    return _buildLogo(logoAsset, effectiveWidth, effectiveHeight);
  }

  Widget _buildLogo(String logoAsset, double width, double height) {
    return Image.asset(
      logoAsset,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackLogo(width, height);
      },
    );
  }

  Widget _buildFallbackLogo(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Text(
          'P',
          style: TextStyle(
            fontSize: (width * 0.4).sp,
            fontWeight: FontWeight.bold,
            color: textColor ?? AppConstants.primaryColor,
            fontFamily: AppConstants.fontFamily,
          ),
        ),
      ),
    );
  }

  String _getLogoAsset() {
    switch (type) {
      case LogoType.main:
        return AppConstants.logoMain;
      case LogoType.app:
        return AppConstants.logoApp;
      case LogoType.icon:
        return AppConstants.logoIcon;
    }
  }
}

enum LogoType {
  main,
  app,
  icon,
}

// Convenience widget for text with Partt branding
class ParttText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ParttText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style?.copyWith(
        fontFamily: AppConstants.fontFamily,
        color: color ?? style?.color,
        fontSize: fontSize?.sp ?? style?.fontSize,
        fontWeight: fontWeight ?? style?.fontWeight,
      ) ?? TextStyle(
        fontFamily: AppConstants.fontFamily,
        color: color ?? AppConstants.textPrimary,
        fontSize: fontSize?.sp ?? 14.sp,
        fontWeight: fontWeight ?? FontWeight.w400,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

// Convenience widget for headings with Partt branding
class ParttHeading extends StatelessWidget {
  final String text;
  final HeadingType type;
  final Color? color;
  final TextAlign? textAlign;

  const ParttHeading(
    this.text, {
    super.key,
    this.type = HeadingType.h3,
    this.color,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ParttText(
      text,
      fontSize: _getFontSize(),
      fontWeight: _getFontWeight(),
      color: color ?? AppConstants.textPrimary,
      textAlign: textAlign,
    );
  }

  double _getFontSize() {
    switch (type) {
      case HeadingType.h1:
        return 32;
      case HeadingType.h2:
        return 24;
      case HeadingType.h3:
        return 20;
      case HeadingType.h4:
        return 18;
      case HeadingType.h5:
        return 16;
      case HeadingType.h6:
        return 14;
    }
  }

  FontWeight _getFontWeight() {
    switch (type) {
      case HeadingType.h1:
      case HeadingType.h2:
        return FontWeight.bold;
      case HeadingType.h3:
      case HeadingType.h4:
        return FontWeight.w600;
      case HeadingType.h5:
      case HeadingType.h6:
        return FontWeight.w500;
    }
  }
}

enum HeadingType {
  h1,
  h2,
  h3,
  h4,
  h5,
  h6,
}

// Branded AppBar with logo
class ParttAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showLogo;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ParttAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showLogo = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showLogo
          ? Padding(
              padding: EdgeInsets.all(8.w),
              child: const ParttLogo.appBar(),
            )
          : onBackPressed != null
              ? IconButton(
                  onPressed: onBackPressed,
                  icon: const Icon(Icons.arrow_back),
                )
              : null,
      title: ParttText(
        title,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: foregroundColor ?? Colors.white,
      ),
      backgroundColor: backgroundColor ?? AppConstants.primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      actions: actions,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}