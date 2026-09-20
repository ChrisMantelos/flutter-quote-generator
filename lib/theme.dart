import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class QuotePalette extends ThemeExtension<QuotePalette> {
  final Color paper;
  final Color ink;
  final Color inkSoft;
  final Color accent;
  final Color accentBg;
  final Color chipBorder;
  final Color cardBg;

  const QuotePalette({
    required this.paper,
    required this.ink,
    required this.inkSoft,
    required this.accent,
    required this.accentBg,
    required this.chipBorder,
    required this.cardBg,
  });

  static const light = QuotePalette(
    paper: Color(0xFFF7F2EA),
    ink: Color(0xFF2B2118),
    inkSoft: Color(0xFF6B5D4F),
    accent: Color(0xFF7A2E2E),
    accentBg: Color(0xFFF0E0DD),
    chipBorder: Color(0xFFD8CBB8),
    cardBg: Colors.white,
  );

  static const dark = QuotePalette(
    paper: Color(0xFF1C1712),
    ink: Color(0xFFEDE6DA),
    inkSoft: Color(0xFFB8AA97),
    accent: Color(0xFFE0928C),
    accentBg: Color(0xFF3A2626),
    chipBorder: Color(0xFF4A3F33),
    cardBg: Color(0xFF241E18),
  );

  @override
  QuotePalette copyWith({
    Color? paper,
    Color? ink,
    Color? inkSoft,
    Color? accent,
    Color? accentBg,
    Color? chipBorder,
    Color? cardBg,
  }) {
    return QuotePalette(
      paper: paper ?? this.paper,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      accent: accent ?? this.accent,
      accentBg: accentBg ?? this.accentBg,
      chipBorder: chipBorder ?? this.chipBorder,
      cardBg: cardBg ?? this.cardBg,
    );
  }

  @override
  QuotePalette lerp(ThemeExtension<QuotePalette>? other, double t) {
    if (other is! QuotePalette) return this;
    return QuotePalette(
      paper: Color.lerp(paper, other.paper, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentBg: Color.lerp(accentBg, other.accentBg, t)!,
      chipBorder: Color.lerp(chipBorder, other.chipBorder, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
    );
  }
}

class QuoteTextStyles {
  static TextStyle quote(Color color, double size) => GoogleFonts.crimsonPro(
        fontSize: size,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.4,
      );

  static TextStyle author(Color color) => GoogleFonts.ibmPlexSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.3,
      );

  static TextStyle label(Color color) => GoogleFonts.ibmPlexMono(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.8,
      );

  static TextStyle chip(Color color) => GoogleFonts.ibmPlexMono(
        fontSize: 12,
        color: color,
      );

  static TextStyle title(Color color) => GoogleFonts.crimsonPro(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        color: color,
      );
}

ThemeData buildAppTheme(QuotePalette palette, Brightness brightness) {
  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: palette.paper,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: palette.accent,
      brightness: brightness,
      surface: palette.paper,
    ),
    extensions: [palette],
  );
}
