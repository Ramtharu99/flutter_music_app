import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextstyles {
  static TextStyle h1 = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );
  static TextStyle h2 = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );
  static TextStyle h3 = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  //bold text

  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
  );
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  //button text
  static TextStyle buttonLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  static TextStyle buttonMedium = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
  static TextStyle buttonSmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  //label text

  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  //helper function for color variable
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  //helper function for font weight
  static TextStyle withFontWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
}
