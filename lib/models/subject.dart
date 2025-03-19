import 'package:flutter/material.dart';
import 'package:studystack/models/note.dart';

class Subject {
  final String id;
  final String label;
  final String professor;
  final int credit;
  final String branchCode;
  final Color color;
  final IconData icon;
  final List<Note> notes;

  Subject({
    required this.id,
    required this.label,
    required this.professor,
    required this.credit,
    required this.branchCode,
    required this.color,
    required this.icon,
    this.notes = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'professor': professor,
      'credit': credit,
      'branchCode': branchCode,
      'color': color.value,
      'icon': icon.codePoint,
      'notes': notes.map((note) => note.toMap()).toList(),
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] ?? '',
      label: map['label'],
      professor: map['professor'],
      credit: map['credit'],
      branchCode: map['branchCode'],
      color: Color(map['color']),
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
      notes:
          (map['notes'] as List?)?.map((note) => Note.fromMap(note)).toList() ??
              [],
    );
  }
}
