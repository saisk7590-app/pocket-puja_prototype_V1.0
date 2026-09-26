import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Golden "Liquid Glass" design tokens — extracted 1:1 from the Stitch
/// mockups (Material 3 golden/amber palette).
class AppColors {
  AppColors._();

  static const primary = Color(0xFFF2CA50);
  static const primaryFixed = Color(0xFFFFE088);
  static const primaryFixedDim = Color(0xFFE9C349);
  static const primaryContainer = Color(0xFFD4AF37);
  static const onPrimary = Color(0xFF3C2F00);

  static const background = Color(0xFF141311);
  static const surface = Color(0xFF141311);
  static const surfaceContainer = Color(0xFF20201D);
  static const surfaceContainerLow = Color(0xFF1C1C19);
  static const surfaceContainerLowest = Color(0xFF0F0E0C);
  static const surfaceContainerHigh = Color(0xFF2B2A27);
  static const surfaceContainerHighest = Color(0xFF363532);
  static const surfaceVariant = Color(0xFF363532);
  static const surfaceBright = Color(0xFF3A3936);

  static const onBackground = Color(0xFFE6E2DD);
  static const onSurface = Color(0xFFE6E2DD);
  static const onSurfaceVariant = Color(0xFFD0C5AF);
  static const outline = Color(0xFF99907C);
  static const outlineVariant = Color(0xFF4D4635);

  static const secondary = Color(0xFFFFB693);
  static const secondaryContainer = Color(0xFF953C01);
  static const secondaryFixedDim = Color(0xFFFFB693);

  static const tertiaryContainer = Color(0xFFFF949A);
  static const error = Color(0xFFFFB4AB);
  static const errorContainer = Color(0xFF93000A);

  // Gradient stops used for the amber "sacred" background across screens.
  static const gradientDeep = Color(0xFF351000);
  static const gradientMid = Color(0xFF561F00);
  static const gradientWarm = Color(0xFF953C01);
  static const gradientRust = Color(0xFF7A2F00);
  static const gradientMaroon = Color(0xFF7A1F2B);
  static const gradientOrange = Color(0xFFC9622A);

  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
}

class AppGradients {
  AppGradients._();

  static const sacred = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gradientDeep, AppColors.gradientMid, AppColors.gradientWarm],
    stops: [0.0, 0.4, 1.0],
  );

  static const auth = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gradientMaroon, AppColors.gradientOrange],
  );

  static const rust = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gradientDeep, AppColors.gradientRust, AppColors.gradientDeep],
  );

  static const subtleDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3C2F00), AppColors.background],
  );

  static const goldButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryContainer],
  );
}

class AppTheme {
  AppTheme._();

  static TextTheme get _textTheme => TextTheme(
        headlineLarge: GoogleFonts.notoSansTelugu(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        headlineMedium: GoogleFonts.notoSansTelugu(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        headlineSmall: GoogleFonts.notoSansTelugu(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.onSurface),
        bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 16, color: AppColors.onSurface),
        bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.onSurfaceVariant),
        bodySmall: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.onSurfaceVariant),
        labelLarge: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
      );

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          error: AppColors.error,
          outline: AppColors.outline,
        ),
        textTheme: _textTheme,
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
        iconTheme: const IconThemeData(color: AppColors.primary),
        dividerColor: Colors.white12,
        splashFactory: InkRipple.splashFactory,
      );

  /// Text shadow used for the glowing gold headline accents.
  static List<Shadow> get goldGlow => [
        Shadow(color: AppColors.primary.withValues(alpha: 0.6), blurRadius: 12),
      ];
}
