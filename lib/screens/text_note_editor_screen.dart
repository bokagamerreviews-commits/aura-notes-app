import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/note_model.dart';
import '../state/app_controller.dart';
import '../widgets/themed_background.dart';
import '../widgets/themed_surfaces.dart';

class TextNoteEditorScreen extends StatefulWidget {
  final AppController controller;
  final NoteItem? existingNote;

  const TextNoteEditorScreen({
    super.key,
    required this.controller,
    this.existingNote,
  });

  @override
  State<TextNoteEditorScreen> createState() => _TextNoteEditorScreenState();
}

class _TextNoteEditorScreenState extends State<TextNoteEditorScreen> {
  late NoteItem _workingNote;
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  // Undo / Redo snapshots
  final List<(String, String)> _undoStack = [];
  final List<(String, String)> _redoStack = [];
  bool _isApplyingHistory = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _workingNote = widget.existingNote?.copyWith() ??
        NoteItem(
          id: 'note_${now.microsecondsSinceEpoch}',
          title: '',
          type: NoteType.text,
          createdAt: now,
          updatedAt: now,
          content: '',
        );

    _titleController = TextEditingController(text: _workingNote.title);
    _contentController = TextEditingController(text: _workingNote.content);
    _undoStack.add((_workingNote.title, _workingNote.content));

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (_isApplyingHistory) return;
    final newTitle = _titleController.text;
    final newContent = _contentController.text;
    if (_undoStack.isEmpty ||
        _undoStack.last.$1 != newTitle ||
        _undoStack.last.$2 != newContent) {
      _undoStack.add((newTitle, newContent));
      if (_undoStack.length > 50) _undoStack.removeAt(0);
      _redoStack.clear();
    }
    _autoSave();
    setState(() {});
  }

  Future<void> _autoSave() async {
    final title = _titleController.text;
    final content = _contentController.text;
    if (title.trim().isEmpty && content.trim().isEmpty) return;

    _workingNote = _workingNote.copyWith(
      title: title,
      content: content,
      updatedAt: DateTime.now(),
    );
    await widget.controller.upsertNote(_workingNote);
  }

  void _undo() {
    if (_undoStack.length <= 1) return;
    _isApplyingHistory = true;
    final current = _undoStack.removeLast();
    _redoStack.add(current);
    final previous = _undoStack.last;
    _titleController.text = previous.$1;
    _contentController.text = previous.$2;
    _isApplyingHistory = false;
    _autoSave();
    setState(() {});
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    _isApplyingHistory = true;
    final next = _redoStack.removeLast();
    _undoStack.add(next);
    _titleController.text = next.$1;
    _contentController.text = next.$2;
    _isApplyingHistory = false;
    _autoSave();
    setState(() {});
  }

  Future<void> _copyNote() async {
    final text = _workingNote.toShareableText();
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('নোটটি ক্লিপবোর্ডে কপি করা হয়েছে!')),
      );
    }
  }

  Future<void> _shareNote() async {
    await _autoSave();
    final text = _workingNote.toShareableText();
    if (text.isNotEmpty) {
      await Share.share(text);
    }
  }

  Future<void> _confirmAndDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('নোট ডিলিট করবেন?'),
        content: const Text('এই নোটটি স্থায়ীভাবে (Permanent) ডিলিট হয়ে যাবে।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('বাতিল'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ডিলিট করুন'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await widget.controller.deleteNotePermanently(_workingNote.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.controller.themeState;
    final primaryText = theme.primaryTextColor;
    final cardText = theme.cardTextColor;

    return ThemedBackground(
      theme: theme,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: primaryText),
          title: Text(
            'Text Note',
            style: TextStyle(
              color: primaryText,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Undo',
              onPressed: _undoStack.length > 1 ? _undo : null,
              icon: const Icon(Icons.undo_rounded),
            ),
            IconButton(
              tooltip: 'Redo',
              onPressed: _redoStack.isNotEmpty ? _redo : null,
              icon: const Icon(Icons.redo_rounded),
            ),
            IconButton(
              tooltip: _workingNote.isPinned ? 'Unpin' : 'Pin Note',
              onPressed: () async {
                setState(() {
                  _workingNote = _workingNote.copyWith(
                    isPinned: !_workingNote.isPinned,
                  );
                });
                await _autoSave();
              },
              icon: Icon(
                _workingNote.isPinned
                    ? Icons.push_pin_rounded
                    : Icons.push_pin_outlined,
                color: _workingNote.isPinned ? theme.activeAccent : primaryText,
              ),
            ),
            IconButton(
              tooltip: 'Copy Note',
              onPressed: _copyNote,
              icon: const Icon(Icons.copy_rounded),
            ),
            IconButton(
              tooltip: 'Share Note',
              onPressed: _shareNote,
              icon: const Icon(Icons.share_rounded),
            ),
            IconButton(
              tooltip: 'Delete Permanently',
              onPressed: _confirmAndDelete,
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                Expanded(
                  child: ThemedCardContainer(
                    theme: theme,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          style: TextStyle(
                            color: cardText,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: InputDecoration(
                            hintText: 'নোটের টাইটেল লিখুন...',
                            hintStyle: TextStyle(
                              color: cardText.withOpacity(0.45),
                              fontWeight: FontWeight.w700,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                        Divider(color: cardText.withOpacity(0.18), height: 18),
                        Expanded(
                          child: TextField(
                            controller: _contentController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: TextStyle(
                              color: cardText,
                              fontSize: 16,
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'এখানে আপনার নোট লিখুন (বাংলা, English বা কিবোর্ডের ভয়েস টাইপিং)...',
                              hintStyle: TextStyle(
                                color: cardText.withOpacity(0.42),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ThemedActionButton(
                      theme: theme,
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Save & Close',
                      onTap: () async {
                        await _autoSave();
                        if (mounted) Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
