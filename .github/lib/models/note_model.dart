import 'dart:convert';

enum NoteType {
  text,
  table,
  todo,
}

class TodoItem {
  String id;
  String text;
  bool isCompleted;

  TodoItem({
    required this.id,
    required this.text,
    this.isCompleted = false,
  });

  TodoItem copyWith({
    String? id,
    String? text,
    bool? isCompleted,
  }) {
    return TodoItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isCompleted': isCompleted,
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
        text: json['text']?.toString() ?? '',
        isCompleted: json['isCompleted'] == true,
      );
}

class NoteItem {
  final String id;
  String title;
  NoteType type;
  bool isPinned;
  DateTime createdAt;
  DateTime updatedAt;

  // For Text Note
  String content;

  // For Table Note (2D List of Strings, default 10 rows x 3 columns)
  List<List<String>> tableData;

  // For To-Do Checklist Note
  List<TodoItem> todoItems;

  NoteItem({
    required this.id,
    required this.title,
    required this.type,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
    this.content = '',
    List<List<String>>? tableData,
    List<TodoItem>? todoItems,
  })  : tableData = tableData ?? _defaultTable(),
        todoItems = todoItems ?? [];

  static List<List<String>> _defaultTable() {
    return List.generate(
      10,
      (r) => List.generate(
        3,
        (c) => r == 0 ? 'Column ${c + 1}' : '',
      ),
    );
  }

  NoteItem copyWith({
    String? id,
    String? title,
    NoteType? type,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? content,
    List<List<String>>? tableData,
    List<TodoItem>? todoItems,
  }) {
    return NoteItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      content: content ?? this.content,
      tableData: tableData != null
          ? tableData.map((row) => List<String>.from(row)).toList()
          : this.tableData.map((row) => List<String>.from(row)).toList(),
      todoItems: todoItems != null
          ? todoItems.map((item) => item.copyWith()).toList()
          : this.todoItems.map((item) => item.copyWith()).toList(),
    );
  }

  /// Generates clean formatted text for Copy to Clipboard and Android Share
  String toShareableText() {
    final buffer = StringBuffer();
    final cleanTitle = title.trim().isEmpty ? 'Untitled Note' : title.trim();
    buffer.writeln(cleanTitle);
    buffer.writeln('=' * cleanTitle.length.clamp(4, 32));
    buffer.writeln();

    switch (type) {
      case NoteType.text:
        buffer.writeln(content.trim());
        break;
      case NoteType.table:
        if (tableData.isEmpty) break;
        final colCount = tableData.first.length;
        final colWidths = List<int>.filled(colCount, 3);
        for (final row in tableData) {
          for (int c = 0; c < row.length && c < colCount; c++) {
            final cellLen = row[c].trim().length;
            if (cellLen > colWidths[c]) {
              colWidths[c] = cellLen;
            }
          }
        }
        for (int r = 0; r < tableData.length; r++) {
          final row = tableData[r];
          final cells = <String>[];
          for (int c = 0; c < colCount; c++) {
            final val = c < row.length ? row[c].trim() : '';
            cells.add(val.padRight(colWidths[c]));
          }
          buffer.writeln('| ${cells.join(' | ')} |');
          if (r == 0) {
            final sep = colWidths.map((w) => '-' * w).join(' | ');
            buffer.writeln('| $sep |');
          }
        }
        break;
      case NoteType.todo:
        final pending = todoItems.where((t) => !t.isCompleted).toList();
        final completed = todoItems.where((t) => t.isCompleted).toList();
        for (final item in pending) {
          if (item.text.trim().isNotEmpty) {
            buffer.writeln('[ ] ${item.text.trim()}');
          }
        }
        for (final item in completed) {
          if (item.text.trim().isNotEmpty) {
            buffer.writeln('[x] ${item.text.trim()}');
          }
        }
        break;
    }
    return buffer.toString().trim();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
        'isPinned': isPinned,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'content': content,
        'tableData': tableData,
        'todoItems': todoItems.map((e) => e.toJson()).toList(),
      };

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type']?.toString() ?? 'text';
    final parsedType = NoteType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => NoteType.text,
    );

    List<List<String>> parsedTable = [];
    if (json['tableData'] is List) {
      for (final row in (json['tableData'] as List)) {
        if (row is List) {
          parsedTable.add(row.map((cell) => cell?.toString() ?? '').toList());
        }
      }
    }
    if (parsedTable.isEmpty) {
      parsedTable = _defaultTable();
    }

    List<TodoItem> parsedTodos = [];
    if (json['todoItems'] is List) {
      for (final item in (json['todoItems'] as List)) {
        if (item is Map<String, dynamic>) {
          parsedTodos.add(TodoItem.fromJson(item));
        } else if (item is Map) {
          parsedTodos.add(TodoItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return NoteItem(
      id: json['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? '',
      type: parsedType,
      isPinned: json['isPinned'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      content: json['content']?.toString() ?? '',
      tableData: parsedTable,
      todoItems: parsedTodos,
    );
  }

  static String encodeList(List<NoteItem> notes) =>
      jsonEncode(notes.map((n) => n.toJson()).toList());

  static List<NoteItem> decodeList(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! List) return [];
    return decoded
        .map((e) => NoteItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
