import 'package:flutter/material.dart';

enum AppThemeStyle {
  botanicalGlass, // Theme 1: Frosted Glassmorphism + custom background photo
  cyberSoloHud,   // Theme 2: Solo Leveling Dark Neon HUD + custom glow color
  tactileNeumorph,// Theme 3: 3D Tactile Neumorphism + custom base & accent color
  luxuryDual,     // Theme 4: Luxury Dual-Mode (Beige Sand <-> Imperial Green)
  liquidGlass,    // Theme 5: Refractive 3D Liquid Glass + custom base & glow color
}

enum LuxurySubMode {
  beigeSand,
  imperialGreen,
}

class ThemeCustomizationState {
  final AppThemeStyle activeStyle;

  // Theme 1 customization: Custom background image path (null = built-in botanical wallpaper)
  final String? botanicalCustomImagePath;

  // Theme 2 customization: Neon HUD accent/glow color
  final Color cyberAccentColor;

  // Theme 3 customization: Neumorphic base surface & glowing accent colors
  final Color neumorphBaseColor;
  final Color neumorphDarkCardColor;
  final Color neumorphAccentColor;

  // Theme 4 customization: Dual-mode switch (Beige Sand vs Imperial Green)
  final LuxurySubMode luxurySubMode;

  // Theme 5 customization: Liquid Glass base tint & glow accent color
  final Color liquidBaseColor;
  final Color liquidAccentColor;

  const ThemeCustomizationState({
    this.activeStyle = AppThemeStyle.botanicalGlass,
    this.botanicalCustomImagePath,
    this.cyberAccentColor = const Color(0xFFB855F7),
    this.neumorphBaseColor = const Color(0xFFE6EBF0),
    this.neumorphDarkCardColor = const Color(0xFF2B313A),
    this.neumorphAccentColor = const Color(0xFF10B981),
    this.luxurySubMode = LuxurySubMode.beigeSand,
    this.liquidBaseColor = const Color(0xFFDDE3EA),
    this.liquidAccentColor = const Color(0xFF38BDF8),
  });

  ThemeCustomizationState copyWith({
    AppThemeStyle? activeStyle,
    String? botanicalCustomImagePath,
    bool clearBotanicalImage = false,
    Color? cyberAccentColor,
    Color? neumorphBaseColor,
    Color? neumorphDarkCardColor,
    Color? neumorphAccentColor,
    LuxurySubMode? luxurySubMode,
    Color? liquidBaseColor,
    Color? liquidAccentColor,
  }) {
    return ThemeCustomizationState(
      activeStyle: activeStyle ?? this.activeStyle,
      botanicalCustomImagePath: clearBotanicalImage
          ? null
          : (botanicalCustomImagePath ?? this.botanicalCustomImagePath),
      cyberAccentColor: cyberAccentColor ?? this.cyberAccentColor,
      neumorphBaseColor: neumorphBaseColor ?? this.neumorphBaseColor,
      neumorphDarkCardColor: neumorphDarkCardColor ?? this.neumorphDarkCardColor,
      neumorphAccentColor: neumorphAccentColor ?? this.neumorphAccentColor,
      luxurySubMode: luxurySubMode ?? this.luxurySubMode,
      liquidBaseColor: liquidBaseColor ?? this.liquidBaseColor,
      liquidAccentColor: liquidAccentColor ?? this.liquidAccentColor,
    );
  }

  /// Resolved colors for the currently active theme
  Color get scaffoldBackground {
    switch (activeStyle) {
      case AppThemeStyle.botanicalGlass:
        return const Color(0xFFDCE5DC);
      case AppThemeStyle.cyberSoloHud:
        return const Color(0xFF0D0C14);
      case AppThemeStyle.tactileNeumorph:
        return neumorphBaseColor;
      case AppThemeStyle.luxuryDual:
        return luxurySubMode == LuxurySubMode.beigeSand
            ? const Color(0xFFF5EFE6)
            : const Color(0xFF0A180E);
      case AppThemeStyle.liquidGlass:
        return liquidBaseColor;
    }
  }

  Color get primaryTextColor {
    switch (activeStyle) {
      case AppThemeStyle.botanicalGlass:
        return const Color(0xFF16261A);
      case AppThemeStyle.cyberSoloHud:
        return const Color(0xFFF5F3FF);
      case AppThemeStyle.tactileNeumorph:
        return _isLight(neumorphBaseColor)
            ? const Color(0xFF1F2733)
            : const Color(0xFFF1F5F9);
      case AppThemeStyle.luxuryDual:
        return luxurySubMode == LuxurySubMode.beigeSand
            ? const Color(0xFF1C1B18)
            : const Color(0xFFE6C565);
      case AppThemeStyle.liquidGlass:
        return _isLight(liquidBaseColor)
            ? const Color(0xFF1E293B)
            : const Color(0xFFF8FAFC);
    }
  }

  Color get cardTextColor {
    switch (activeStyle) {
      case AppThemeStyle.botanicalGlass:
        return const Color(0xFF182A1C);
      case AppThemeStyle.cyberSoloHud:
        return const Color(0xFFF3E8FF);
      case AppThemeStyle.tactileNeumorph:
        return _isLight(neumorphBaseColor)
            ? const Color(0xFF1F2733)
            : const Color(0xFFF8FAFC);
      case AppThemeStyle.luxuryDual:
        return luxurySubMode == LuxurySubMode.beigeSand
            ? const Color(0xFFF3E8D2)
            : const Color(0xFFE8C86B);
      case AppThemeStyle.liquidGlass:
        return _isLight(liquidBaseColor)
            ? const Color(0xFF1E293B)
            : const Color(0xFFF8FAFC);
    }
  }

  Color get cardSubTextColor {
    return cardTextColor.withOpacity(0.74);
  }

  Color get activeAccent {
    switch (activeStyle) {
      case AppThemeStyle.botanicalGlass:
        return const Color(0xFF478956);
      case AppThemeStyle.cyberSoloHud:
        return cyberAccentColor;
      case AppThemeStyle.tactileNeumorph:
        return neumorphAccentColor;
      case AppThemeStyle.luxuryDual:
        return luxurySubMode == LuxurySubMode.beigeSand
            ? const Color(0xFFD6B98C)
            : const Color(0xFFE5C158);
      case AppThemeStyle.liquidGlass:
        return liquidAccentColor;
    }
  }

  static bool _isLight(Color c) => c.computeLuminance() > 0.45;
}
