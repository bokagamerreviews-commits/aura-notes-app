import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme_config.dart';

/// Renders a card surface that dynamically morphs into any of the 5 UI references
class ThemedCardContainer extends StatelessWidget {
  final ThemeCustomizationState theme;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool useDarkNeumorphVariant;
  final bool showLuxuryGoldFooter;
  final Widget? luxuryFooterChild;

  const ThemedCardContainer({
    super.key,
    required this.theme,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 22,
    this.useDarkNeumorphVariant = false,
    this.showLuxuryGoldFooter = false,
    this.luxuryFooterChild,
  });

  @override
  Widget build(BuildContext context) {
    switch (theme.activeStyle) {
      case AppThemeStyle.botanicalGlass:
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.52),
                    Colors.white.withOpacity(0.28),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.65),
                  width: 1.3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1D3B23).withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );

      case AppThemeStyle.cyberSoloHud:
        final accent = theme.cyberAccentColor;
        return Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFF161424).withOpacity(0.94),
            borderRadius: BorderRadius.circular(borderRadius * 0.8),
            border: Border.all(
              color: accent.withOpacity(0.65),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.28),
                blurRadius: 14,
                spreadRadius: 0.5,
              ),
              const BoxShadow(
                color: Colors.black87,
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: child,
        );

      case AppThemeStyle.tactileNeumorph:
        final base = useDarkNeumorphVariant
            ? theme.neumorphDarkCardColor
            : theme.neumorphBaseColor;
        final hsl = HSLColor.fromColor(base);
        final lightShadow = hsl
            .withLightness((hsl.lightness + 0.12).clamp(0.0, 1.0))
            .toColor();
        final darkShadow = hsl
            .withLightness((hsl.lightness - 0.14).clamp(0.0, 1.0))
            .toColor();

        return Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                hsl.withLightness((hsl.lightness + 0.03).clamp(0.0, 1.0)).toColor(),
                base,
                hsl.withLightness((hsl.lightness - 0.03).clamp(0.0, 1.0)).toColor(),
              ],
            ),
            border: Border.all(
              color: lightShadow.withOpacity(0.55),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: darkShadow.withOpacity(0.75),
                offset: const Offset(6, 6),
                blurRadius: 14,
              ),
              BoxShadow(
                color: lightShadow.withOpacity(0.85),
                offset: const Offset(-5, -5),
                blurRadius: 12,
              ),
            ],
          ),
          child: child,
        );

      case AppThemeStyle.luxuryDual:
        final isSand = theme.luxurySubMode == LuxurySubMode.beigeSand;
        final cardBg = isSand ? const Color(0xFF1D1C19) : const Color(0xFF14301D);
        final cardBgTop = isSand ? const Color(0xFF282622) : const Color(0xFF1E442A);
        final borderGold = isSand ? const Color(0xFFD6B98C) : const Color(0xFFE5C158);

        if (!showLuxuryGoldFooter) {
          return Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius * 0.85),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cardBgTop, cardBg],
              ),
              border: Border.all(
                color: borderGold.withOpacity(0.38),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.32),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          );
        }

        // Layered Luxury Card with Metallic Gold Bottom Bar (Reference Image 4)
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius * 0.85),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: isSand
                  ? const [
                      Color(0xFFC8AE85),
                      Color(0xFFE5D2B2),
                      Color(0xFFCBB188),
                    ]
                  : const [
                      Color(0xFFD4A73A),
                      Color(0xFFF6DC7A),
                      Color(0xFFCE9E2E),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  padding: padding,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius * 0.85),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [cardBgTop, cardBg],
                    ),
                    border: Border.all(
                      color: borderGold.withOpacity(0.45),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
              if (luxuryFooterChild != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: luxuryFooterChild!,
                ),
            ],
          ),
        );

      case AppThemeStyle.liquidGlass:
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.76),
                    Colors.white.withOpacity(0.42),
                    theme.liquidAccentColor.withOpacity(0.08),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.92),
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 4,
                    offset: const Offset(-1, -1),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
    }
  }
}

/// Renders a Pill / Action Button matching the active theme's reference image
class ThemedActionButton extends StatelessWidget {
  final ThemeCustomizationState theme;
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isDestructive;
  final EdgeInsetsGeometry padding;

  const ThemedActionButton({
    super.key,
    required this.theme,
    required this.label,
    this.icon,
    required this.onTap,
    this.isPrimary = true,
    this.isDestructive = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
  });

  @override
  Widget build(BuildContext context) {
    final accent = isDestructive ? const Color(0xFFEF4444) : theme.activeAccent;

    Decoration buttonDecoration;
    Color textColor;

    switch (theme.activeStyle) {
      case AppThemeStyle.botanicalGlass:
        buttonDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isPrimary
                ? [accent.withOpacity(0.92), accent]
                : [Colors.white.withOpacity(0.65), Colors.white.withOpacity(0.38)],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.7),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(isPrimary ? 0.30 : 0.10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
        textColor = isPrimary ? Colors.white : const Color(0xFF182A1C);
        break;

      case AppThemeStyle.cyberSoloHud:
        buttonDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: isPrimary
                ? [accent.withOpacity(0.85), accent.withOpacity(0.55)]
                : [const Color(0xFF211E34), const Color(0xFF171526)],
          ),
          border: Border.all(
            color: accent,
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.45),
              blurRadius: 12,
              spreadRadius: 0.5,
            ),
          ],
        );
        textColor = Colors.white;
        break;

      case AppThemeStyle.tactileNeumorph:
        // Glowing rim pill button like Reference 3 ("Input" green glowing button)
        buttonDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isPrimary
                ? [
                    HSLColor.fromColor(accent)
                        .withLightness(
                            (HSLColor.fromColor(accent).lightness + 0.10)
                                .clamp(0.0, 1.0))
                        .toColor(),
                    accent,
                  ]
                : [
                    Colors.white,
                    theme.neumorphBaseColor,
                  ],
          ),
          border: Border.all(
            color: isPrimary ? Colors.white.withOpacity(0.85) : Colors.white,
            width: 1.6,
          ),
          boxShadow: [
            if (isPrimary)
              BoxShadow(
                color: accent.withOpacity(0.55),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              offset: const Offset(4, 4),
              blurRadius: 8,
            ),
          ],
        );
        textColor = isPrimary ? Colors.white : const Color(0xFF1E293B);
        break;

      case AppThemeStyle.luxuryDual:
        final isSand = theme.luxurySubMode == LuxurySubMode.beigeSand;
        buttonDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: isPrimary
                ? (isSand
                    ? const [Color(0xFFDCC39B), Color(0xFFC4A574)]
                    : const [Color(0xFFF3D773), Color(0xFFD1A234)])
                : [const Color(0xFF282622), const Color(0xFF1D1C19)],
          ),
          border: Border.all(
            color: accent.withOpacity(0.8),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        );
        textColor = isPrimary ? const Color(0xFF141412) : accent;
        break;

      case AppThemeStyle.liquidGlass:
        // Refractive 3D Liquid Glass Pill Button like Reference 5 ("Create Project")
        buttonDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isPrimary
                ? [
                    accent.withOpacity(0.75),
                    HSLColor.fromColor(accent)
                        .withLightness(
                            (HSLColor.fromColor(accent).lightness - 0.16)
                                .clamp(0.0, 1.0))
                        .toColor()
                        .withOpacity(0.88),
                  ]
                : [
                    Colors.white.withOpacity(0.82),
                    Colors.white.withOpacity(0.50),
                  ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.92),
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: (isPrimary ? accent : Colors.black).withOpacity(0.32),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        );
        textColor = isPrimary ? Colors.white : const Color(0xFF1E293B);
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: padding,
          decoration: buttonDecoration,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: textColor),
                const SizedBox(width: 7),
              ],
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
