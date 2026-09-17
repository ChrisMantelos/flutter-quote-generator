import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuoteColors {
  static const paper = Color(0xFFF7F2EA);
  static const ink = Color(0xFF2B2118);
  static const inkSoft = Color(0xFF6B5D4F);
  static const accent = Color(0xFF7A2E2E);
  static const accentBg = Color(0xFFF0E0DD);
  static const chipBorder = Color(0xFFD8CBB8);
}

class QuoteText {
  static TextStyle quote(double size) => GoogleFonts.crimsonPro(
        fontSize: size,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
        color: QuoteColors.ink,
        height: 1.4,
      );

  static TextStyle author = GoogleFonts.ibmPlexSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: QuoteColors.accent,
    letterSpacing: 0.3,
  );

  static TextStyle label = GoogleFonts.ibmPlexMono(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: QuoteColors.inkSoft,
    letterSpacing: 0.8,
  );

  static TextStyle chip = GoogleFonts.ibmPlexMono(
    fontSize: 12,
    color: QuoteColors.ink,
  );

  static TextStyle title = GoogleFonts.crimsonPro(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    color: QuoteColors.ink,
  );
}
