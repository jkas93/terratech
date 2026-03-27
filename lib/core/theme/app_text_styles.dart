import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get heading => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w800, // ExtraBold
        color: AppColors.colorPrimaryDark,
      );

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700, // Bold
        color: AppColors.colorTextPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400, // Regular
        color: AppColors.colorTextPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.colorTextSecondary,
      );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700, // Bold
        color: AppColors.colorPrimary,
      );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600, // SemiBold
        color: AppColors.colorTextMuted,
        letterSpacing: 1.2,
      );
}
