import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/note_model.dart';
import '../state/app_controller.dart';
import '../theme/app_theme_config.dart';
import '../widgets/themed_background.dart';
import '../widgets/themed_surfaces.dart';
import 'table_note_editor_screen.dart';
import 'text_note_editor_screen.dart';
import 'theme_studio_sheet.dart';
import 'todo_note_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppController controller;

  const HomeScreen({
    super.key,
    required this.controller,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isCreateMenuOpen = false;

  void _toggleCreateMenu() {
    setState(() {
      _isCreateMenuOpen = !_isCreateMenuOpen;
    });
  }

  Future<void> _openEditor(NoteType type, [NoteItem? existingNote]) async {
    setState(() {
      _isCreateMenuOpen = false;
    });

    Widget screen;
    switch (type) {
      case NoteType.text:
        screen = TextNoteEditorScreen(
          controller: widget.controller,
          existingNote: existingNote,
        );
        break;
      case NoteType.table:
        screen = TableNoteEditorScreen(
          controller: widget.controller,
          existingNote: existingNote,
        );
        break;
      case NoteType.todo:
        screen = TodoNoteEditorScreen(
          controller: widget.controller,
          existingNote: existingNote,
        );
        break;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  /// Long-Press Action Sheet on any Square Note Card:
  /// Shows Open/Edit, Pin/Unpin, Copy to Clipboard, Share, and Permanent Delete
  Future<void> _showCardHoldActions(NoteItem note) async {
    HapticFeedback.mediumImpact();
    final theme = widget.controller.themeState;
    final textColor = theme.primaryTextColor;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
          decoration: BoxDecoration(
            color: theme.scaffoldBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: theme.activeAccent.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.28),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                note.title.trim().isEmpty ? 'Untitled Note' : note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              // 1. Pin / Unpin Action
              _buildActionTile(
                icon: note.isPinned
                    ? Icons.push_pin_outlined
                    : Icons.push_pin_rounded,
                label: note.isPinned
                    ? 'Unpin Note (পিন সরান)'
                    : 'Pin to Top (উপরে পিন করুন)',
                color: theme.activeAccent,
                textColor: textColor,
                onTap: () async {
                  Navigator.pop(ctx);
                  await widget.controller.togglePin(note.id);
                },
              ),
              const SizedBox(height: 8),
              // 2. Copy to Clipboard Action
              _buildActionTile(
                icon: Icons.copy_rounded,
                label: 'Copy Note (কপি করুন)',
                color: theme.activeAccent,
                textColor: textColor,
                onTap: () async {
                  Navigator.pop(ctx);
                  await Clipboard.setData(
                    ClipboardData(text: note.toShareableText()),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('নোটটি ক্লিপবোর্ডে কপি করা হয়েছে!'),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
              // 3. Share Action
              _buildActionTile(
                icon: Icons.share_rounded,
                label: 'Share Note (শেয়ার করুন)',
                color: theme.activeAccent,
                textColor: textColor,
                onTap: () async {
                  Navigator.pop(ctx);
                  await Share.share(note.toShareableText());
                },
              ),
              const SizedBox(height: 8),
              // 4. Permanent Delete Action
              _buildActionTile(
                icon: Icons.delete_forever_rounded,
                label: 'Delete Permanently (স্থায়ীভাবে ডিলিট করুন)',
                color: const Color(0xFFEF4444),
                textColor: const Color(0xFFEF4444),
                isDestructive: true,
                onTap: () async {
                  Navigator.pop(ctx);
                  await _confirmPermanentDelete(note);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmPermanentDelete(NoteItem note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('স্থায়ীভাবে ডিলিট করবেন?'),
        content: Text(
          '"${note.title.trim().isEmpty ? 'Untitled Note' : note.title}" নোটটি চিরতরে মুছে যাবে।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('না, থাক'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('হ্যাঁ, ডিলিট করুন'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.controller.deleteNotePermanently(note.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('নোটটি স্থায়ীভাবে ডিলিট করা হয়েছে।')),
        );
      }
    }
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isDestructive
                ? const Color(0xFFEF4444).withOpacity(0.12)
                : color.withOpacity(0.10),
            border: Border.all(
              color: isDestructive
                  ? const Color(0xFFEF4444).withOpacity(0.45)
                  : color.withOpacity(0.28),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final theme = widget.controller.themeState;
        final notes = widget.controller.notes;
        final primaryText = theme.primaryTextColor;

        return ThemedBackground(
          theme: theme,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Header Bar (No Search Bar, Clean Title + Theme Studio Switcher)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _headerTitleForTheme(theme),
                                    style: TextStyle(
                                      color: primaryText,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing:
                                          theme.activeStyle == AppThemeStyle.cyberSoloHud
                                              ? 1.4
                                              : 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'নোটের ওপর চেপে ধরে রাখলে (Hold) ডিলিট ও শেয়ার অপশন আসবে',
                                    style: TextStyle(
                                      color: primaryText.withOpacity(0.68),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Quick Dual-Mode Toggle when Theme 4 is active
                            if (theme.activeStyle == AppThemeStyle.luxuryDual)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: IconButton(
                                  tooltip: 'Switch Sand / Imperial Green',
                                  onPressed: () {
                                    final nextMode = theme.luxurySubMode ==
                                            LuxurySubMode.beigeSand
                                        ? LuxurySubMode.imperialGreen
                                        : LuxurySubMode.beigeSand;
                                    widget.controller.updateTheme(
                                      theme.copyWith(luxurySubMode: nextMode),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.swap_horiz_rounded,
                                    color: theme.activeAccent,
                                  ),
                                ),
                              ),
                            ThemedActionButton(
                              theme: theme,
                              icon: Icons.palette_rounded,
                              label: 'Themes',
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              onTap: () {
                                showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => ThemeStudioSheet(
                                    controller: widget.controller,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Square Note Grid
                      Expanded(
                        child: notes.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: ThemedCardContainer(
                                    theme: theme,
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.note_add_rounded,
                                          size: 48,
                                          color: theme.activeAccent,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'এখনো কোনো নোট নেই',
                                          style: TextStyle(
                                            color: theme.cardTextColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'নিচের ডান পাশের (+) বাটনে ট্যাপ করে Text, Table অথবা To-Do নোট তৈরি করুন।',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: theme.cardSubTextColor,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 1.0, // Strictly Square Note Cards
                                ),
                                itemCount: notes.length,
                                itemBuilder: (context, index) {
                                  final note = notes[index];
                                  return _buildSquareNoteCard(note, index, theme);
                                },
                              ),
                      ),
                    ],
                  ),

                  // Tap-outside backdrop when right-side popup menu is open
                  if (_isCreateMenuOpen)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () => setState(() => _isCreateMenuOpen = false),
                        child: Container(
                          color: Colors.black.withOpacity(0.28),
                        ),
                      ),
                    ),

                  // Right-Side Popup Menu with 3 Creation Buttons (Text, Table, To-Do)
                  Positioned(
                    right: 20,
                    bottom: 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isCreateMenuOpen) ...[
                          _buildPopupCreateButton(
                            theme: theme,
                            icon: Icons.edit_note_rounded,
                            label: 'Text Note',
                            onTap: () => _openEditor(NoteType.text),
                          ),
                          const SizedBox(height: 10),
                          _buildPopupCreateButton(
                            theme: theme,
                            icon: Icons.table_chart_rounded,
                            label: 'Table (10×3)',
                            onTap: () => _openEditor(NoteType.table),
                          ),
                          const SizedBox(height: 10),
                          _buildPopupCreateButton(
                            theme: theme,
                            icon: Icons.checklist_rounded,
                            label: 'To-Do List',
                            onTap: () => _openEditor(NoteType.todo),
                          ),
                          const SizedBox(height: 14),
                        ],
                        // Main Floating Create (+) Trigger
                        ThemedActionButton(
                          theme: theme,
                          icon: _isCreateMenuOpen
                              ? Icons.close_rounded
                              : Icons.add_rounded,
                          label: _isCreateMenuOpen ? 'Close' : 'Create Note',
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          onTap: _toggleCreateMenu,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _headerTitleForTheme(ThemeCustomizationState theme) {
    switch (theme.activeStyle) {
      case AppThemeStyle.botanicalGlass:
        return 'Aura Notes 🌿';
      case AppThemeStyle.cyberSoloHud:
        return 'SYSTEM NOTES';
      case AppThemeStyle.tactileNeumorph:
        return 'Tactile Notes';
      case AppThemeStyle.luxuryDual:
        return theme.luxurySubMode == LuxurySubMode.beigeSand
            ? 'Beige Sand Notes'
            : 'Imperial Notes';
      case AppThemeStyle.liquidGlass:
        return 'Liquid Glass Notes';
    }
  }

  Widget _buildPopupCreateButton({
    required ThemeCustomizationState theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ThemedActionButton(
      theme: theme,
      icon: icon,
      label: label,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      onTap: onTap,
    );
  }

  Widget _buildSquareNoteCard(
    NoteItem note,
    int index,
    ThemeCustomizationState theme,
  ) {
    final useDarkNeumorph =
        theme.activeStyle == AppThemeStyle.tactileNeumorph && index.isOdd;
    final cardText = useDarkNeumorph ? Colors.white : theme.cardTextColor;
    final subText =
        useDarkNeumorph ? Colors.white70 : theme.cardSubTextColor;

    return GestureDetector(
      onTap: () => _openEditor(note.type, note),
      onLongPress: () => _showCardHoldActions(note),
      child: ThemedCardContainer(
        theme: theme,
        useDarkNeumorphVariant: useDarkNeumorph,
        showLuxuryGoldFooter: theme.activeStyle == AppThemeStyle.luxuryDual,
        luxuryFooterChild: theme.activeStyle == AppThemeStyle.luxuryDual
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _badgeLabelForNote(note),
                    style: const TextStyle(
                      color: Color(0xFF141412),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                  const Icon(
                    Icons.more_horiz_rounded,
                    size: 16,
                    color: Color(0xFF141412),
                  ),
                ],
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Type Badge + Pin Indicator
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.activeAccent.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.activeAccent.withOpacity(0.5),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _iconForNoteType(note.type),
                        size: 12,
                        color: cardText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _badgeLabelForNote(note),
                        style: TextStyle(
                          color: cardText,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (note.isPinned)
                  Icon(
                    Icons.push_pin_rounded,
                    size: 16,
                    color: theme.activeAccent,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Note Title
            Text(
              note.title.trim().isEmpty ? 'Untitled' : note.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cardText,
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            // Note Body Preview
            Expanded(
              child: _buildPreviewContent(note, cardText, subText, theme),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForNoteType(NoteType type) {
    switch (type) {
      case NoteType.text:
        return Icons.notes_rounded;
      case NoteType.table:
        return Icons.grid_on_rounded;
      case NoteType.todo:
        return Icons.check_box_outlined;
    }
  }

  String _badgeLabelForNote(NoteItem note) {
    switch (note.type) {
      case NoteType.text:
        return 'Text';
      case NoteType.table:
        final rows = note.tableData.length;
        final cols = rows > 0 ? note.tableData.first.length : 0;
        return 'Table $rows×$cols';
      case NoteType.todo:
        final done = note.todoItems.where((t) => t.isCompleted).length;
        return '$done/${note.todoItems.length} Done';
    }
  }

  Widget _buildPreviewContent(
    NoteItem note,
    Color cardText,
    Color subText,
    ThemeCustomizationState theme,
  ) {
    switch (note.type) {
      case NoteType.text:
        return Text(
          note.content.trim().isEmpty ? 'খালি নোট...' : note.content.trim(),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: subText,
            fontSize: 12.5,
            height: 1.35,
          ),
        );

      case NoteType.table:
        final previewRows = note.tableData.take(3).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: previewRows.asMap().entries.map((entry) {
            final isHeader = entry.key == 0;
            final cells = entry.value.take(3).map((e) => e.trim().isEmpty ? '—' : e).join(' | ');
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                cells,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isHeader ? cardText : subText,
                  fontSize: 11.5,
                  fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        );

      case NoteType.todo:
        final previewItems = note.todoItems.take(3).toList();
        if (previewItems.isEmpty) {
          return Text(
            'কোনো আইটেম নেই...',
            style: TextStyle(color: subText, fontSize: 12),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: previewItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                children: [
                  Icon(
                    item.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 13,
                    color: item.isCompleted ? theme.activeAccent : subText,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      item.text.trim().isEmpty ? '...' : item.text.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: subText,
                        fontSize: 12,
                        decoration: item.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
    }
  }
}
