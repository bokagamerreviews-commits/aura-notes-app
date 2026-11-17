import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme_config.dart';

class ThemedBackground extends StatelessWidget {
  final ThemeCustomizationState theme;
  final Widget child;

  const ThemedBackground({
    super.key,
    required this.theme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackdropLayer(),
        child,
      ],
    );
  }

  Widget _buildBackdropLayer() {
    switch (theme.activeStyle) {
      case AppThemeStyle.botanicalGlass:
        return _BotanicalGlassBackdrop(
          customImagePath: theme.botanicalCustomImagePath,
        );
      case AppThemeStyle.cyberSoloHud:
        return _CyberSoloHudBackdrop(accentColor: theme.cyberAccentColor);
      case AppThemeStyle.tactileNeumorph:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _shiftLightness(theme.neumorphBaseColor, 0.04),
                theme.neumorphBaseColor,
                _shiftLightness(theme.neumorphBaseColor, -0.05),
              ],
            ),
          ),
        );
      case AppThemeStyle.luxuryDual:
        final isSand = theme.luxurySubMode == LuxurySubMode.beigeSand;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.3),
              radius: 1.25,
              colors: isSand
                  ? const [
                      Color(0xFFFAF5EE),
                      Color(0xFFF3ECE0),
                      Color(0xFFEBE1D1),
                    ]
                  : const [
                      Color(0xFF132A19),
                      Color(0xFF0B190E),
                      Color(0xFF060F08),
                    ],
            ),
          ),
        );
      case AppThemeStyle.liquidGlass:
        return _LiquidGlassStudioBackdrop(
          baseColor: theme.liquidBaseColor,
          accentColor: theme.liquidAccentColor,
        );
    }
  }

  Color _shiftLightness(Color color, double delta) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + delta).clamp(0.0, 1.0))
        .toColor();
  }
}

class _BotanicalGlassBackdrop extends StatelessWidget {
  final String? customImagePath;

  const _BotanicalGlassBackdrop({this.customImagePath});

  @override
  Widget build(BuildContext context) {
    final hasCustomFile = customImagePath != null &&
        customImagePath!.isNotEmpty &&
        File(customImagePath!).existsSync();

    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasCustomFile)
          Image.file(
            File(customImagePath!),
            fit: BoxFit.cover,
          )
        else
          CustomPaint(
            painter: _BuiltInBotanicalPainter(),
          ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            color: Colors.white.withOpacity(0.18),
          ),
        ),
      ],
    );
  }
}

/// Built-in lush Monstera & tropical leaf artwork so Theme 1 looks like Reference 1 out-of-the-box
class _BuiltInBotanicalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgRect = Offset.zero & size;
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE4ECE2),
          Color(0xFFC8DAC6),
          Color(0xFFB3CBB0),
          Color(0xFFDAE4D8),
        ],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);

    // Soft organic bokeh blobs representing tropical foliage
    final blobs = [
      (Offset(size.width * 0.15, size.height * 0.22), size.width * 0.45, const Color(0xFF2D5E38).withOpacity(0.55)),
      (Offset(size.width * 0.85, size.height * 0.18), size.width * 0.38, const Color(0xFF427A4E).withOpacity(0.45)),
      (Offset(size.width * 0.72, size.height * 0.55), size.width * 0.52, const Color(0xFF1E4627).withOpacity(0.50)),
      (Offset(size.width * 0.20, size.height * 0.78), size.width * 0.48, const Color(0xFF3B6E47).withOpacity(0.50)),
      (Offset(size.width * 0.50, size.height * 0.42), size.width * 0.35, const Color(0xFF689F72).withOpacity(0.35)),
    ];

    for (final b in blobs) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [b.$3, b.$3.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: b.$1, radius: b.$2));
      canvas.drawCircle(b.$1, b.$2, paint);
    }

    // Draw stylized Monstera leaf silhouettes
    _drawLeaf(canvas, Offset(size.width * 0.12, size.height * 0.28), 140, -0.4, const Color(0xFF24502E).withOpacity(0.45));
    _drawLeaf(canvas, Offset(size.width * 0.82, size.height * 0.62), 170, 0.5, const Color(0xFF1E4627).withOpacity(0.42));
    _drawLeaf(canvas, Offset(size.width * 0.25, size.height * 0.82), 130, -0.2, const Color(0xFF336940).withOpacity(0.38));
  }

  void _drawLeaf(Canvas canvas, Offset center, double radius, double angle, Color color) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(0, -radius)
      ..cubicTo(radius * 0.85, -radius * 0.7, radius * 0.9, radius * 0.5, 0, radius)
      ..cubicTo(-radius * 0.9, radius * 0.5, -radius * 0.85, -radius * 0.7, 0, -radius)
      ..close();
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CyberSoloHudBackdrop extends StatelessWidget {
  final Color accentColor;

  const _CyberSoloHudBackdrop({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CyberHudPainter(accentColor: accentColor),
    );
  }
}

class _CyberHudPainter extends CustomPainter {
  final Color accentColor;

  _CyberHudPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF12101E),
          Color(0xFF0B0A12),
          Color(0xFF08070D),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Top radial aura glow matching Reference 2
    final auraPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.65),
        radius: 0.9,
        colors: [
          accentColor.withOpacity(0.24),
          accentColor.withOpacity(0.06),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, auraPaint);

    // Subtle HUD radar rings in background
    final ringPaint = Paint()
      ..color = accentColor.withOpacity(0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final center = Offset(size.width * 0.75, size.height * 0.32);
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, i * 48.0, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CyberHudPainter oldDelegate) =>
      oldDelegate.accentColor != accentColor;
}

class _LiquidGlassStudioBackdrop extends StatelessWidget {
  final Color baseColor;
  final Color accentColor;

  const _LiquidGlassStudioBackdrop({
    required this.baseColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(baseColor);
    final lighter = hsl.withLightness((hsl.lightness + 0.06).clamp(0.0, 1.0)).toColor();
    final darker = hsl.withLightness((hsl.lightness - 0.06).clamp(0.0, 1.0)).toColor();

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [lighter, baseColor, darker],
            ),
          ),
        ),
        // Subtle refractive studio light orbs
        Positioned(
          top: -60,
          right: -40,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accentColor.withOpacity(0.18),
                  accentColor.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -80,
          left: -40,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.35),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
