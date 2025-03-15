import 'package:studystack/models/note.dart';

class Subject {
  final String label;
  final String imageUrl;
  final String professor;
  final int credit;
  final String branch;
  final List<Note> notes;

  Subject({
    required this.label,
    required this.imageUrl,
    required this.professor,
    required this.credit,
    required this.branch,
    this.notes = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'imageUrl': imageUrl,
      'professor': professor,
      'credit': credit,
      'branch': branch,
      'notes': notes.map((note) => note.toMap()).toList(),
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      label: map['label'],
      imageUrl: map['imageUrl'],
      professor: map['professor'],
      credit: map['credit'],
      branch: map['branch'],
      notes: (map['notes'] as List<dynamic>)
          .map((note) => Note.fromMap(note))
          .toList(),
    );
  }
}
