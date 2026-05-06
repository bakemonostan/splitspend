import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppPalette {
  // Primary (#0F766E)
  static const Color primary10 = Color(0xFFF1F2F2);
  static const Color primary50 = Color(0xFFE6F4F2);
  static const Color primary100 = Color(0xFFCEEAE7);
  static const Color primary200 = Color(0xFF9DD5CF);
  static const Color primary300 = Color(0xFF6CBFB7);
  static const Color primary400 = Color(0xFF3BAA9F);
  static const Color primary500 = Color(0xFF0F766E);
  static const Color primary600 = Color(0xFF0C5E58);
  static const Color primary700 = Color(0xFF094742);
  static const Color primary800 = Color(0xFF062F2C);
  static const Color primary900 = Color(0xFF031816);

  // Secondary (#64748B)
  static const Color secondary50 = Color(0xFFF0F2F5);
  static const Color secondary100 = Color(0xFFE0E5EC);
  static const Color secondary200 = Color(0xFFC2CBD8);
  static const Color secondary300 = Color(0xFFA3B1C5);
  static const Color secondary400 = Color(0xFF8598B1);
  static const Color secondary500 = Color(0xFF64748B);
  static const Color secondary600 = Color(0xFF505D6F);
  static const Color secondary700 = Color(0xFF3C4653);
  static const Color secondary800 = Color(0xFF282E38);
  static const Color secondary900 = Color(0xFF14171C);

  // Tertiary (#9C573A)
  static const Color tertiary50 = Color(0xFFF9EEEA);
  static const Color tertiary100 = Color(0xFFF2DED5);
  static const Color tertiary200 = Color(0xFFE5BEAB);
  static const Color tertiary300 = Color(0xFFD89D80);
  static const Color tertiary400 = Color(0xFFCA7D56);
  static const Color tertiary500 = Color(0xFF9C573A);
  static const Color tertiary600 = Color(0xFF7D462E);
  static const Color tertiary700 = Color(0xFF5D3423);
  static const Color tertiary800 = Color(0xFF3E2317);
  static const Color tertiary900 = Color(0xFF1F110C);

  // Neutral (#747877)
  static const Color neutral50 = Color(0xFFF1F2F2);
  static const Color neutral100 = Color(0xFFE3E4E4);
  static const Color neutral200 = Color(0xFFC7C9C9);
  static const Color neutral300 = Color(0xFFABAEAD);
  static const Color neutral400 = Color(0xFF8F9392);
  static const Color neutral500 = Color(0xFF747877);
  static const Color neutral600 = Color(0xFF5D605F);
  static const Color neutral700 = Color(0xFF464847);
  static const Color neutral800 = Color(0xFF2E3030);
  static const Color neutral900 = Color(0xFF171818);
}

class AppColors {
  static const Color primary = AppPalette.primary500;
  static const Color secondary = AppPalette.secondary500;
  static const Color tertiary = AppPalette.tertiary500;
  static const Color neutral = AppPalette.neutral500;
}

ThemeData primaryTheme = ThemeData(
  textTheme: GoogleFonts.interTextTheme().copyWith(
    headlineLarge: GoogleFonts.manrope(
      fontWeight: FontWeight.w700,
      fontSize: 24,
    ),
    headlineMedium: GoogleFonts.manrope(
      fontWeight: FontWeight.w600,
      fontSize: 20,
    ),
    titleLarge: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 18),
    bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 16),
    labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
  ),
);
