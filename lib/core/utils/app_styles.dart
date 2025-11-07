import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  // Colors - Updated to match blue gradient design
  static const Color primaryColor = Color(0xFF288DE5); // Light blue from gradient
  static const Color secondaryColor = Color(0xFF164E7F); // Dark blue from gradient
  static const Color accentColor = Color(0xFFFFC107);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color blackColor = Color(0xFF000000);
  static const Color darkGreyColor = Color(0xFF333333);
  static const Color mediumGreyColor = Color(0xFF4F4F4F);
  static const Color lightGreyColor = Color(0xFF9E9E9E);
  static const Color greyColor = Color(0xFFF5F5F5);
  static const Color choco = Color.fromARGB(255, 108, 102, 98);
  // Default red for danger/error states
  static const Color dangerColor = Color(0xFFEE6868);

  // Responsive utilities
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isSmallScreen(BuildContext context) {
    return getScreenWidth(context) < 360;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= 360 && width < 414;
  }

  static bool isLargeScreen(BuildContext context) {
    return getScreenWidth(context) >= 414;
  }

  // Responsive spacing
  static double getResponsiveSpacing(BuildContext context, {
    double small = 8.0,
    double medium = 12.0,
    double large = 16.0,
  }) {
    if (isSmallScreen(context)) return small;
    if (isMediumScreen(context)) return medium;
    return large;
  }

  // Responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context, {
    EdgeInsets? small,
    EdgeInsets? medium,
    EdgeInsets? large,
  }) {
    small ??= const EdgeInsets.all(12.0);
    medium ??= const EdgeInsets.all(16.0);
    large ??= const EdgeInsets.all(20.0);

    if (isSmallScreen(context)) return small;
    if (isMediumScreen(context)) return medium;
    return large;
  }

  // Responsive font sizes
  static double getResponsiveFontSize(BuildContext context, {
    double small = 12.0,
    double medium = 14.0,
    double large = 16.0,
  }) {
    if (isSmallScreen(context)) return small;
    if (isMediumScreen(context)) return medium;
    return large;
  }

  // Responsive dimensions
  static double getResponsiveWidth(BuildContext context, double percentage) {
    return getScreenWidth(context) * percentage;
  }

  static double getResponsiveHeight(BuildContext context, double percentage) {
    return getScreenHeight(context) * percentage;
  }

  // Responsive Text Styles
  static TextStyle heading1(BuildContext context) => GoogleFonts.poppins(
    fontSize: getResponsiveFontSize(context, small: 20.0, medium: 22.0, large: 24.0),
    fontWeight: FontWeight.bold,
    color: whiteColor,
  );

  static TextStyle heading2(BuildContext context) => GoogleFonts.poppins(
    fontSize: getResponsiveFontSize(context, small: 18.0, medium: 19.0, large: 20.0),
    fontWeight: FontWeight.bold,
    color: darkGreyColor,
  );

  static TextStyle subheading(BuildContext context) => GoogleFonts.poppins(
    fontSize: getResponsiveFontSize(context, small: 14.0, medium: 15.0, large: 16.0),
    color: whiteColor.withOpacity(0.8),
  );

  static TextStyle bodyText(BuildContext context) => GoogleFonts.poppins(
    fontSize: getResponsiveFontSize(context, small: 12.0, medium: 13.0, large: 14.0),
    color: darkGreyColor,
  );

  static TextStyle headerGreeting(BuildContext context) => GoogleFonts.poppins(
    fontSize: getResponsiveFontSize(context, small: 12.0, medium: 13.0, large: 14.0),
    fontWeight: FontWeight.w400,
    color: whiteColor,
  );

  static TextStyle headerUsername(BuildContext context) => GoogleFonts.poppins(
    fontSize: getResponsiveFontSize(context, small: 14.0, medium: 15.0, large: 16.0),
    fontWeight: FontWeight.w600,
    color: whiteColor,
  );

  static TextStyle cardUsername(BuildContext context) => GoogleFonts.poppins(
    fontSize: getResponsiveFontSize(context, small: 12.0, medium: 13.0, large: 14.0),
    fontWeight: FontWeight.w600,
    color: blackColor,
  );

  static TextStyle saldoLabel(BuildContext context) => GoogleFonts.poppins(
    fontSize: getResponsiveFontSize(context, small: 10.0, medium: 11.0, large: 12.0),
    fontWeight: FontWeight.w400,
    color: lightGreyColor,
  );

  static TextStyle saldoValue(BuildContext context) => GoogleFonts.poppins(
    fontSize: getResponsiveFontSize(context, small: 16.0, medium: 17.0, large: 18.0),
    fontWeight: FontWeight.w600,
    color: blackColor,
  );

  static TextStyle topUpButton(BuildContext context) => GoogleFonts.poppins(
    fontSize: getResponsiveFontSize(context, small: 10.0, medium: 11.0, large: 12.0),
    fontWeight: FontWeight.w500,
    color: primaryColor,
  );

  static TextStyle transactionHistory(BuildContext context) => GoogleFonts.poppins(
    fontSize: getResponsiveFontSize(context, small: 12.0, medium: 13.0, large: 14.0),
    fontWeight: FontWeight.w600,
    color: primaryColor,
  );

  static TextStyle sectionTitle(BuildContext context) => GoogleFonts.poppins(
    fontSize: getResponsiveFontSize(context, small: 12.0, medium: 13.0, large: 14.0),
    fontWeight: FontWeight.w600,
    color: blackColor,
  );

  static TextStyle facilityDescription(BuildContext context) => GoogleFonts.poppins(
    fontSize: getResponsiveFontSize(context, small: 10.0, medium: 11.0, large: 12.0),
    fontWeight: FontWeight.w400,
    color: mediumGreyColor,
  );

  static TextStyle menuLabel(BuildContext context) => GoogleFonts.poppins(
    fontSize: getResponsiveFontSize(context, small: 10.0, medium: 11.0, large: 12.0),
    fontWeight: FontWeight.w500,
    color: blackColor,
  );

  static TextStyle bottomNavActive(BuildContext context) => GoogleFonts.poppins(
    fontSize: getResponsiveFontSize(context, small: 10.0, medium: 11.0, large: 12.0),
    fontWeight: FontWeight.w500,
    color: primaryColor,
  );

  static TextStyle bottomNavInactive(BuildContext context) => GoogleFonts.poppins(
    fontSize: getResponsiveFontSize(context, small: 10.0, medium: 11.0, large: 12.0),
    fontWeight: FontWeight.w400,
    color: lightGreyColor,
  );

  // Responsive container dimensions
  static double getCardBorderRadius(BuildContext context) {
    return getResponsiveFontSize(context, small: 8.0, medium: 10.0, large: 12.0);
  }

  static double getButtonBorderRadius(BuildContext context) {
    return getResponsiveFontSize(context, small: 12.0, medium: 14.0, large: 16.0);
  }

  static double getIconSize(BuildContext context, {
    double small = 20.0,
    double medium = 24.0,
    double large = 28.0,
  }) {
    if (isSmallScreen(context)) return small;
    if (isMediumScreen(context)) return medium;
    return large;
  }

  // Grid responsive settings
  static int getGridCrossAxisCount(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 360) return 3; // Small screens: 3 columns
    if (width < 414) return 4; // Medium screens: 4 columns
    return 4; // Large screens: 4 columns
  }

  static double getGridChildAspectRatio(BuildContext context) {
    if (isSmallScreen(context)) return 0.8;
    if (isMediumScreen(context)) return 0.85;
    return 0.9;
  }

  // Safe area and status bar handling
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  // Responsive image dimensions
  static double getImageSize(BuildContext context, {
    double small = 100.0,
    double medium = 120.0,
    double large = 150.0,
  }) {
    if (isSmallScreen(context)) return small;
    if (isMediumScreen(context)) return medium;
    return large;
  }
}
