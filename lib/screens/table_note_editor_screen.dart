import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/note_model.dart';
import '../state/app_controller.dart';
import '../widgets/themed_background.dart';
import '../widgets/themed_surfaces.dart';

class TableNoteEditorScreen extends StatefulWidget {
  final AppController controller;
  final NoteItem? existingNote;

  const TableNoteEditorScreen({
    super.key,
    required this.controller,
    this.existingNote,
  });

  @override
  State<TableNoteEditorScreen> createState() => _TableNoteEditorScreenState();
}

class _TableNoteEditorScreenState extends State<TableNoteEditorScreen> {
  late NoteItem _workingNote;
  late TextEditingController _titleController;
  late List<List<TextEditingController>> _cellControllers;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _workingNote = widget.existingNote?.copyWith() ??
        NoteItem(
          id: 'table_${now.microsecondsSinceEpoch}',
          title: '',
          type: NoteType.table,
          createdAt: now,
          updatedAt: now,
        );

    _titleController = TextEditingController(text: _workingNote.title);
    _titleController.addListener(_syncAndSave);
    _initCellControllers();
  }

  void _initCellControllers() {
    _cellControllers = _workingNote.tableData.map((row) {
      return row.map((cellText) {
        final ctrl = TextEditingController(text: cellText);
        ctrl.addListener(_syncAndSave);
        return ctrl;
      }).toList();
    }).toList();
  }

  void _disposeCellControllers() {
    for (final row in _cellControllers) {
      for (final ctrl in row) {
        ctrl.dispose();
      }
    }
  }

  Future<void> _syncAndSave() async {
    final table = _cellControllers
        .map((row) => row.map((c) => c.text).toList())
        .toList();
    _workingNote = _workingNote.copyWith(
      title: _titleController.text,
      tableData: table,
      updatedAt: DateTime.now(),
    );
    await widget.controller.upsertNote(_workingNote);
  }

  void _addRow() {
    final colCount = _cellControllers.isNotEmpty ? _cellControllers.first.length : 3;
    final newRow = List.generate(colCount, (_) {
      final ctrl = TextEditingController(text: '');
      ctrl.addListener(_syncAndSave);
      return ctrl;
    });
    setState(() {
      _cellControllers.add(newRow);
    });
    _syncAndSave();
  }

  void _addColumn() {
    setState(() {
      for (int r = 0; r < _cellControllers.length; r++) {
        final defaultText =
            r == 0 ? 'Column ${_cellControllers[r].length + 1}' : '';
        final ctrl = TextEditingController(text: defaultText);
        ctrl.addListener(_syncAndSave);
        _cellControllers[r].add(ctrl);
      }
    });
    _syncAndSave();
  }

  void _deleteLastRow() {
    if (_cellControllers.length <= 1) return;
    setState(() {
      final removed = _cellControllers.removeLast();
      for (final c in removed) {
        c.dispose();
      }
    });
    _syncAndSave();
  }

  void _deleteLastColumn() {
    if (_cellControllers.isEmpty || _cellControllers.first.length <= 1) return;
    setState(() {
      for (final row in _cellControllers) {
        final removed = row.removeLast();
        removed.dispose();
      }
    });
    _syncAndSave();
  }

  Future<void> _copyTable() async {
    await _syncAndSave();
    final text = _workingNote.toShareableText();
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('টেবিলটি ক্লিপবোর্ডে কপি করা হয়েছে!')),
      );
    }
  }

  Future<void> _shareTable() async {
    await _syncAndSave();
    final text = _workingNote.toShareableText();
    await Share.share(text);
  }

  Future<void> _confirmAndDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('টেবিল নোট ডিলিট করবেন?'),
        content: const Text('এই টেবিলটি স্থায়ীভাবে (Permanent) ডিলিট হয়ে যাবে।'),
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
    _disposeCellControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.controller.themeState;
    final primaryText = theme.primaryTextColor;
    final cardText = theme.cardTextColor;
    final rowCount = _cellControllers.length;
    final colCount = rowCount > 0 ? _cellControllers.first.length : 0;

    return ThemedBackground(
      theme: theme,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: primaryText),
          title: Text(
            'Table Sheet ($rowCount×$colCount)',
            style: TextStyle(
              color: primaryText,
              fontWeight: FontWeight.w800,
              fontSize: 16.5,
            ),
          ),
          actions: [
            IconButton(
              tooltip: _workingNote.isPinned ? 'Unpin' : 'Pin Table',
              onPressed: () async {
                setState(() {
                  _workingNote = _workingNote.copyWith(
                    isPinned: !_workingNote.isPinned,
                  );
                });
                await _syncAndSave();
              },
              icon: Icon(
                _workingNote.isPinned
                    ? Icons.push_pin_rounded
                    : Icons.push_pin_outlined,
                color: _workingNote.isPinned ? theme.activeAccent : primaryText,
              ),
            ),
            IconButton(
              tooltip: 'Copy Table',
              onPressed: _copyTable,
              icon: const Icon(Icons.copy_rounded),
            ),
            IconButton(
              tooltip: 'Share Table',
              onPressed: _shareTable,
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
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Table Action Toolbar (Add Row, Add Column, Remove Row/Col)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ThemedActionButton(
                        theme: theme,
                        icon: Icons.add_box_rounded,
                        label: 'Add Row',
                        onTap: _addRow,
                      ),
                      const SizedBox(width: 8),
                      ThemedActionButton(
                        theme: theme,
                        icon: Icons.view_column_rounded,
                        label: 'Add Column',
                        onTap: _addColumn,
                      ),
                      const SizedBox(width: 8),
                      ThemedActionButton(
                        theme: theme,
                        isPrimary: false,
                        icon: Icons.remove_circle_outline_rounded,
                        label: 'Row -',
                        onTap: _deleteLastRow,
                      ),
                      const SizedBox(width: 8),
                      ThemedActionButton(
                        theme: theme,
                        isPrimary: false,
                        icon: Icons.remove_circle_outline_rounded,
                        label: 'Col -',
                        onTap: _deleteLastColumn,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ThemedCardContainer(
                    theme: theme,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _titleController,
                          style: TextStyle(
                            color: cardText,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: InputDecoration(
                            hintText: 'টেবিলের নাম লিখুন...',
                            hintStyle: TextStyle(color: cardText.withOpacity(0.45)),
                            border: InputBorder.none,
                          ),
                        ),
                        Divider(color: cardText.withOpacity(0.18), height: 14),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(rowCount, (r) {
                                  final isHeader = r == 0;
                                  return Row(
                                    children: [
                                      // Row Index Badge
                                      Container(
                                        width: 34,
                                        height: 46,
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: theme.activeAccent
                                              .withOpacity(isHeader ? 0.32 : 0.14),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          isHeader ? '#' : '$r',
                                          style: TextStyle(
                                            color: cardText,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      ...List.generate(colCount, (c) {
                                        return Container(
                                          width: 135,
                                          height: 46,
                                          margin: const EdgeInsets.all(2),
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: isHeader
                                                ? theme.activeAccent.withOpacity(0.22)
                                                : cardText.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(9),
                                            border: Border.all(
                                              color: isHeader
                                                  ? theme.activeAccent.withOpacity(0.6)
                                                  : cardText.withOpacity(0.18),
                                              width: isHeader ? 1.4 : 1.0,
                                            ),
                                          ),
                                          alignment: Alignment.centerLeft,
                                          child: TextField(
                                            controller: _cellControllers[r][c],
                                            style: TextStyle(
                                              color: cardText,
                                              fontWeight: isHeader
                                                  ? FontWeight.w800
                                                  : FontWeight.w500,
                                              fontSize: 13.5,
                                            ),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              border: InputBorder.none,
                                              hintText: isHeader ? 'Header' : '...',
                                              hintStyle: TextStyle(
                                                color: cardText.withOpacity(0.30),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ThemedActionButton(
                      theme: theme,
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Save Table',
                      onTap: () async {
                        await _syncAndSave();
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
