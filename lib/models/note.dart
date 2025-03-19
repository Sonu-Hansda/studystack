class Note {
  final String label;
  final String filePath;
  final String uploadedBy;
  final DateTime uploadedAt;

  Note({
    required this.label,
    required this.filePath,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'filePath': filePath,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      label: map['label'],
      filePath: map['filePath'],
      uploadedBy: map['uploadedBy'],
      uploadedAt: DateTime.parse(map['uploadedAt']),
    );
  }
}
