import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/note_model.dart';
import '../state/app_controller.dart';
import '../widgets/themed_background.dart';
import '../widgets/themed_surfaces.dart';

class TodoNoteEditorScreen extends StatefulWidget {
  final AppController controller;
  final NoteItem? existingNote;

  const TodoNoteEditorScreen({
    super.key,
    required this.controller,
    this.existingNote,
  });

  @override
  State<TodoNoteEditorScreen> createState() => _TodoNoteEditorScreenState();
}

class _TodoNoteEditorScreenState extends State<TodoNoteEditorScreen> {
  late NoteItem _workingNote;
  late TextEditingController _titleController;
  final TextEditingController _newItemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _workingNote = widget.existingNote?.copyWith() ??
        NoteItem(
          id: 'todo_${now.microsecondsSinceEpoch}',
          title: '',
          type: NoteType.todo,
          createdAt: now,
          updatedAt: now,
          todoItems: [
            TodoItem(
              id: 'item_${now.microsecondsSinceEpoch}',
              text: '',
              isCompleted: false,
            ),
          ],
        );

    _titleController = TextEditingController(text: _workingNote.title);
    _titleController.addListener(_saveNote);
  }

  Future<void> _saveNote() async {
    _workingNote = _workingNote.copyWith(
      title: _titleController.text,
      updatedAt: DateTime.now(),
    );
    await widget.controller.upsertNote(_workingNote);
  }

  void _addTodoItem([String initialText = '']) {
    setState(() {
      _workingNote.todoItems.insert(
        0,
        TodoItem(
          id: 'item_${DateTime.now().microsecondsSinceEpoch}',
          text: initialText,
          isCompleted: false,
        ),
      );
    });
    _saveNote();
  }

  void _toggleItem(TodoItem item, bool? value) {
    setState(() {
      item.isCompleted = value ?? false;
    });
    _saveNote();
  }

  void _deleteItem(String id) {
    setState(() {
      _workingNote.todoItems.removeWhere((e) => e.id == id);
    });
    _saveNote();
  }

  Future<void> _copyChecklist() async {
    await _saveNote();
    final text = _workingNote.toShareableText();
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('টু-ডু লিস্ট ক্লিপবোর্ডে কপি করা হয়েছে!')),
      );
    }
  }

  Future<void> _shareChecklist() async {
    await _saveNote();
    final text = _workingNote.toShareableText();
    await Share.share(text);
  }

  Future<void> _confirmAndDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('টু-ডু লিস্ট ডিলিট করবেন?'),
        content: const Text('এই তালিকাটি স্থায়ীভাবে (Permanent) ডিলিট হয়ে যাবে।'),
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
    _newItemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.controller.themeState;
    final primaryText = theme.primaryTextColor;
    final cardText = theme.cardTextColor;

    final pendingItems =
        _workingNote.todoItems.where((t) => !t.isCompleted).toList();
    final completedItems =
        _workingNote.todoItems.where((t) => t.isCompleted).toList();
    final totalCount = _workingNote.todoItems.length;
    final doneCount = completedItems.length;

    return ThemedBackground(
      theme: theme,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: primaryText),
          title: Text(
            'To-Do List ($doneCount/$totalCount)',
            style: TextStyle(
              color: primaryText,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          actions: [
            IconButton(
              tooltip: _workingNote.isPinned ? 'Unpin' : 'Pin Checklist',
              onPressed: () async {
                setState(() {
                  _workingNote = _workingNote.copyWith(
                    isPinned: !_workingNote.isPinned,
                  );
                });
                await _saveNote();
              },
              icon: Icon(
                _workingNote.isPinned
                    ? Icons.push_pin_rounded
                    : Icons.push_pin_outlined,
                color: _workingNote.isPinned ? theme.activeAccent : primaryText,
              ),
            ),
            IconButton(
              tooltip: 'Copy Checklist',
              onPressed: _copyChecklist,
              icon: const Icon(Icons.copy_rounded),
            ),
            IconButton(
              tooltip: 'Share Checklist',
              onPressed: _shareChecklist,
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
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: Column(
              children: [
                Expanded(
                  child: ThemedCardContainer(
                    theme: theme,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _titleController,
                          style: TextStyle(
                            color: cardText,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: InputDecoration(
                            hintText: 'টু-ডু লিস্টের টাইটেল...',
                            hintStyle: TextStyle(color: cardText.withOpacity(0.45)),
                            border: InputBorder.none,
                          ),
                        ),
                        // Quick Add Task Bar
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _newItemController,
                                style: TextStyle(color: cardText, fontSize: 15),
                                decoration: InputDecoration(
                                  hintText: 'নতুন কাজ যোগ করুন...',
                                  hintStyle:
                                      TextStyle(color: cardText.withOpacity(0.45)),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (val) {
                                  if (val.trim().isNotEmpty) {
                                    _addTodoItem(val.trim());
                                    _newItemController.clear();
                                  }
                                },
                              ),
                            ),
                            ThemedActionButton(
                              theme: theme,
                              icon: Icons.add_task_rounded,
                              label: 'Add Item',
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 9,
                              ),
                              onTap: () {
                                _addTodoItem(_newItemController.text.trim());
                                _newItemController.clear();
                              },
                            ),
                          ],
                        ),
                        Divider(color: cardText.withOpacity(0.18), height: 20),
                        Expanded(
                          child: ListView(
                            children: [
                              ...pendingItems.map(
                                (item) => _buildTodoRow(item, cardText, theme),
                              ),
                              if (completedItems.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Completed (${completedItems.length})',
                                  style: TextStyle(
                                    color: cardText.withOpacity(0.6),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ...completedItems.map(
                                  (item) => _buildTodoRow(item, cardText, theme),
                                ),
                              ],
                            ],
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
                      label: 'Save List',
                      onTap: () async {
                        await _saveNote();
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

  Widget _buildTodoRow(
    TodoItem item,
    Color cardText,
     dynamic theme,
  ) {
    return KeyedSubtree(
      key: ValueKey(item.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: item.isCompleted,
              activeColor: theme.activeAccent,
              checkColor: Colors.white,
              side: BorderSide(color: cardText.withOpacity(0.5), width: 1.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              onChanged: (val) => _toggleItem(item, val),
            ),
            Expanded(
              child: TextFormField(
                initialValue: item.text,
                style: TextStyle(
                  color: item.isCompleted
                      ? cardText.withOpacity(0.45)
                      : cardText,
                  decoration: item.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  fontSize: 15.5,
                ),
                decoration: InputDecoration(
                  hintText: 'কাজের বিবরণ লিখুন...',
                  hintStyle: TextStyle(color: cardText.withOpacity(0.35)),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (val) {
                  item.text = val;
                  _saveNote();
                },
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: cardText.withOpacity(0.55),
                size: 19,
              ),
              onPressed: () => _deleteItem(item.id),
            ),
          ],
        ),
      ),
    );
  }
}
