import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';
import '../theme/app_theme_config.dart';

class AppController extends ChangeNotifier {
  static const String _notesStorageKey = 'aura_notes_items_v1';
  static const String _themeStorageKey = 'aura_notes_theme_v1';

  List<NoteItem> _notes = [];
  ThemeCustomizationState _themeState = const ThemeCustomizationState();
  bool _isLoaded = false;

  List<NoteItem> get notes {
    final sorted = List<NoteItem>.from(_notes);
    sorted.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return sorted;
  }

  ThemeCustomizationState get themeState => _themeState;
  bool get isLoaded => _isLoaded;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    final rawTheme = prefs.getString(_themeStorageKey);
    if (rawTheme != null && rawTheme.isNotEmpty) {
      try {
        final map = jsonDecode(rawTheme) as Map<String, dynamic>;
        final styleName = map['activeStyle']?.toString() ?? '';
        final style = AppThemeStyle.values.firstWhere(
          (e) => e.name == styleName,
          orElse: () => AppThemeStyle.botanicalGlass,
        );
        final subModeName = map['luxurySubMode']?.toString() ?? '';
        final subMode = LuxurySubMode.values.firstWhere(
          (e) => e.name == subModeName,
          orElse: () => LuxurySubMode.beigeSand,
        );
        _themeState = ThemeCustomizationState(
          activeStyle: style,
          botanicalCustomImagePath: map['botanicalCustomImagePath'] as String?,
          cyberAccentColor: Color(map['cyberAccentColor'] as int? ?? 0xFFB855F7),
          neumorphBaseColor: Color(map['neumorphBaseColor'] as int? ?? 0xFFE6EBF0),
          neumorphDarkCardColor: Color(map['neumorphDarkCardColor'] as int? ?? 0xFF2B313A),
          neumorphAccentColor: Color(map['neumorphAccentColor'] as int? ?? 0xFF10B981),
          luxurySubMode: subMode,
          liquidBaseColor: Color(map['liquidBaseColor'] as int? ?? 0xFFDDE3EA),
          liquidAccentColor: Color(map['liquidAccentColor'] as int? ?? 0xFF38BDF8),
        );
      } catch (_) {}
    }

    final rawNotes = prefs.getString(_notesStorageKey);
    if (rawNotes != null && rawNotes.isNotEmpty) {
      try {
        _notes = NoteItem.decodeList(rawNotes);
      } catch (_) {
        _notes = [];
      }
    } else {
      final now = DateTime.now();
      _notes = [
        NoteItem(
          id: 'welcome_text_1',
          title: 'স্বাগতম! Aura Notes',
          type: NoteType.text,
          isPinned: true,
          createdAt: now,
          updatedAt: now,
          content: 'যেকোনো নোট কার্ডের ওপর কিছুক্ষণ ট্যাপ করে ধরে রাখলে (Long-Press) সাথে সাথে Pin, Copy, Share এবং Permanent Delete করার অপশন সামনে আসবে। উপরের প্যালেট আইকনে ট্যাপ করে ৫টি প্রিমিয়াম থিম এবং কালার কাস্টমাইজ করুন!',
        ),
        NoteItem(
          id: 'sample_todo_2',
          title: 'আজকের কাজের তালিকা',
          type: NoteType.todo,
          isPinned: false,
          createdAt: now.subtract(const Duration(minutes: 5)),
          updatedAt: now.subtract(const Duration(minutes: 5)),
          todoItems: [
            TodoItem(id: 't1', text: 'নতুন ভিডিওর স্ক্রিপ্ট লেখা', isCompleted: true),
            TodoItem(id: 't2', text: 'থাম্বনেইল ডিজাইন ফাইনাল করা', isCompleted: false),
            TodoItem(id: 't3', text: 'ভয়েসওভার রেকর্ড ও সিঙ্ক করা', isCompleted: false),
          ],
        ),
        NoteItem(
          id: 'sample_table_3',
          title: 'প্রজেক্ট শিডিউল টেবিল',
          type: NoteType.table,
          isPinned: false,
          createdAt: now.subtract(const Duration(minutes: 10)),
          updatedAt: now.subtract(const Duration(minutes: 10)),
          tableData: List.generate(
            10,
            (r) => r == 0
                ? ['দিন', 'টপিক', 'স্ট্যাটাস']
                : r == 1
                    ? ['শনিবার', '3D Animation', 'Done']
                    : r == 2
                        ? ['রবিবার', 'History Doc', 'In Progress']
                        : ['', '', ''],
          ),
        ),
      ];
      await _persistNotes();
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _persistNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notesStorageKey, NoteItem.encodeList(_notes));
  }

  Future<void> _persistTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'activeStyle': _themeState.activeStyle.name,
      'botanicalCustomImagePath': _themeState.botanicalCustomImagePath,
      'cyberAccentColor': _themeState.cyberAccentColor.value,
      'neumorphBaseColor': _themeState.neumorphBaseColor.value,
      'neumorphDarkCardColor': _themeState.neumorphDarkCardColor.value,
      'neumorphAccentColor': _themeState.neumorphAccentColor.value,
      'luxurySubMode': _themeState.luxurySubMode.name,
      'liquidBaseColor': _themeState.liquidBaseColor.value,
      'liquidAccentColor': _themeState.liquidAccentColor.value,
    };
    await prefs.setString(_themeStorageKey, jsonEncode(map));
  }

  Future<void> upsertNote(NoteItem updatedNote) async {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index >= 0) {
      _notes[index] = updatedNote;
    } else {
      _notes.insert(0, updatedNote);
    }
    notifyListeners();
    await _persistNotes();
  }

  Future<void> togglePin(String noteId) async {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index < 0) return;
    final current = _notes[index];
    _notes[index] = current.copyWith(
      isPinned: !current.isPinned,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    await _persistNotes();
  }

  Future<void> deleteNotePermanently(String noteId) async {
    _notes.removeWhere((n) => n.id == noteId);
    notifyListeners();
    await _persistNotes();
  }

  Future<void> updateTheme(ThemeCustomizationState newState) async {
    _themeState = newState;
    notifyListeners();
    await _persistTheme();
  }
}
