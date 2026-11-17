import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../state/app_controller.dart';
import '../theme/app_theme_config.dart';
import '../widgets/themed_surfaces.dart';

class ThemeStudioSheet extends StatelessWidget {
  final AppController controller;

  const ThemeStudioSheet({
    super.key,
    required this.controller,
  });

  static const List<Color> _presetAccentColors = [
    Color(0xFFB855F7), // Solo Leveling Electric Purple
    Color(0xFF38BDF8), // Liquid Sky Blue
    Color(0xFF10B981), // Neumorph Emerald Green
    Color(0xFFF59E0B), // Imperial Gold
    Color(0xFFF43F5E), // Cyber Rose Red
    Color(0xFF6366F1), // Royal Indigo
    Color(0xFF14B8A6), // Teal Glow
    Color(0xFFEC4899), // Neon Magenta
  ];

  static const List<Color> _presetBaseColors = [
    Color(0xFFE6EBF0), // Default Soft Off-White
    Color(0xFFDDE3EA), // Frosted Crystal Silver
    Color(0xFFF5EFE6), // Warm Cream Sand
    Color(0xFFDCE8DF), // Mint Mist
    Color(0xFFE6E1F0), // Soft Lavender Mist
    Color(0xFF232830), // Dark Slate Base
    Color(0xFF181C22), // Deep Charcoal Base
  ];

  Future<void> _pickCustomBackground(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        await controller.updateTheme(
          controller.themeState.copyWith(
            botanicalCustomImagePath: picked.path,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ছবি লোড করা যায়নি: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final theme = controller.themeState;
        final textColor = theme.primaryTextColor;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: theme.activeAccent.withOpacity(0.45),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                child: Row(
                  children: [
                    Icon(Icons.palette_rounded, color: theme.activeAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Theme Studio (৫টি কাস্টম থিম)',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: textColor),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
                  children: [
                    _buildThemeOptionCard(
                      context,
                      style: AppThemeStyle.botanicalGlass,
                      title: '1. Botanical Glassmorphism',
                      subtitle: 'ফ্রস্টেড গ্লাস কার্ড + গ্যালারি থেকে ব্যাকগ্রাউন্ড ছবি চেঞ্জ',
                      previewColor: const Color(0xFF478956),
                    ),
                    const SizedBox(height: 10),
                    _buildThemeOptionCard(
                      context,
                      style: AppThemeStyle.cyberSoloHud,
                      title: '2. Solo Leveling Dark Neon HUD',
                      subtitle: 'ডার্ক গেমিং সিস্টেম ইউআই + কাস্টম নিওন গ্লো কালার',
                      previewColor: theme.cyberAccentColor,
                    ),
                    const SizedBox(height: 10),
                    _buildThemeOptionCard(
                      context,
                      style: AppThemeStyle.tactileNeumorph,
                      title: '3. Tactile 3D Neumorphism',
                      subtitle: 'সফট থ্রিডি বাটন ও কার্ড + বেস ও অ্যাকসেন্ট কালার চেঞ্জ',
                      previewColor: theme.neumorphAccentColor,
                    ),
                    const SizedBox(height: 10),
                    _buildThemeOptionCard(
                      context,
                      style: AppThemeStyle.luxuryDual,
                      title: '4. Luxury Dual-Mode (Sand & Imperial)',
                      subtitle: 'Beige Sand এবং Imperial Green মোড সুইচার',
                      previewColor: const Color(0xFFD4AF37),
                    ),
                    const SizedBox(height: 10),
                    _buildThemeOptionCard(
                      context,
                      style: AppThemeStyle.liquidGlass,
                      title: '5. Refractive 3D Liquid Glass',
                      subtitle: 'লিকুইড গ্লাস পিল ইউআই + বেস ও গ্লো কালার কাস্টমাইজেশন',
                      previewColor: theme.liquidAccentColor,
                    ),
                    const SizedBox(height: 20),
                    Divider(color: textColor.withOpacity(0.15)),
                    const SizedBox(height: 12),
                    Text(
                      'বর্তমান থিমের কাস্টমাইজেশন অপশন:',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActiveThemeCustomizer(context, theme, textColor),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOptionCard(
    BuildContext context, {
    required AppThemeStyle style,
    required String title,
    required String subtitle,
    required Color previewColor,
  }) {
    final theme = controller.themeState;
    final isSelected = theme.activeStyle == style;
    final textColor = theme.primaryTextColor;

    return InkWell(
      onTap: () => controller.updateTheme(theme.copyWith(activeStyle: style)),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isSelected
              ? previewColor.withOpacity(0.18)
              : textColor.withOpacity(0.05),
          border: Border.all(
            color: isSelected ? previewColor : textColor.withOpacity(0.16),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: previewColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: previewColor.withOpacity(0.45),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                isSelected ? Icons.check_rounded : Icons.style_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveThemeCustomizer(
    BuildContext context,
    ThemeCustomizationState theme,
    Color textColor,
  ) {
    switch (theme.activeStyle) {
      case AppThemeStyle.botanicalGlass:
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ThemedActionButton(
              theme: theme,
              icon: Icons.photo_library_rounded,
              label: 'গ্যালারি থেকে ব্যাকগ্রাউন্ড ছবি দিন',
              onTap: () => _pickCustomBackground(context),
            ),
            if (theme.botanicalCustomImagePath != null)
              ThemedActionButton(
                theme: theme,
                isPrimary: false,
                icon: Icons.refresh_rounded,
                label: 'ডিফল্ট ওয়ালপেপারে ফিরুন',
                onTap: () => controller.updateTheme(
                  theme.copyWith(clearBotanicalImage: true),
                ),
              ),
          ],
        );

      case AppThemeStyle.cyberSoloHud:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Neon Glow & HUD Color নির্বাচন করুন:',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _buildColorSwatchRow(
              colors: _presetAccentColors,
              selectedColor: theme.cyberAccentColor,
              onSelect: (c) =>
                  controller.updateTheme(theme.copyWith(cyberAccentColor: c)),
            ),
          ],
        );

      case AppThemeStyle.tactileNeumorph:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '১. Base Surface Color (সাদা/অফ-হোয়াইট বা ডার্ক বেস):',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _buildColorSwatchRow(
              colors: _presetBaseColors,
              selectedColor: theme.neumorphBaseColor,
              onSelect: (c) =>
                  controller.updateTheme(theme.copyWith(neumorphBaseColor: c)),
            ),
            const SizedBox(height: 16),
            Text(
              '২. 3D Glowing Accent Color:',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _buildColorSwatchRow(
              colors: _presetAccentColors,
              selectedColor: theme.neumorphAccentColor,
              onSelect: (c) => controller
                  .updateTheme(theme.copyWith(neumorphAccentColor: c)),
            ),
          ],
        );

      case AppThemeStyle.luxuryDual:
        final isSand = theme.luxurySubMode == LuxurySubMode.beigeSand;
        return Row(
          children: [
            Expanded(
              child: ThemedActionButton(
                theme: theme,
                isPrimary: isSand,
                icon: Icons.wb_sunny_outlined,
                label: 'Beige Sand Mode',
                onTap: () => controller.updateTheme(
                  theme.copyWith(luxurySubMode: LuxurySubMode.beigeSand),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ThemedActionButton(
                theme: theme,
                isPrimary: !isSand,
                icon: Icons.auto_awesome_rounded,
                label: 'Imperial Green',
                onTap: () => controller.updateTheme(
                  theme.copyWith(luxurySubMode: LuxurySubMode.imperialGreen),
                ),
              ),
            ),
          ],
        );

      case AppThemeStyle.liquidGlass:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '১. Studio Base Tint Color:',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _buildColorSwatchRow(
              colors: _presetBaseColors,
              selectedColor: theme.liquidBaseColor,
              onSelect: (c) =>
                  controller.updateTheme(theme.copyWith(liquidBaseColor: c)),
            ),
            const SizedBox(height: 16),
            Text(
              '২. Liquid Glass Glow Color:',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _buildColorSwatchRow(
              colors: _presetAccentColors,
              selectedColor: theme.liquidAccentColor,
              onSelect: (c) =>
                  controller.updateTheme(theme.copyWith(liquidAccentColor: c)),
            ),
          ],
        );
    }
  }

  Widget _buildColorSwatchRow({
    required List<Color> colors,
    required Color selectedColor,
    required ValueChanged<Color> onSelect,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((c) {
        final isSelected = c.value == selectedColor.value;
        return GestureDetector(
          onTap: () => onSelect(c),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.black26,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: c.withOpacity(0.65),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: isSelected
                ? Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: c.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
