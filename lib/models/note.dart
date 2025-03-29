class Note {
  final String id;
  final String label;
  final String filePath;
  final String uploadedBy;
  final DateTime uploadedAt;

  Note({
    this.id = '',
    required this.label,
    required this.filePath,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  Note copyWith({
    String? id,
    String? label,
    String? filePath,
    String? uploadedBy,
    DateTime? uploadedAt,
  }) {
    return Note(
      id: id ?? this.id,
      label: label ?? this.label,
      filePath: filePath ?? this.filePath,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'filePath': filePath,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      label: map['label'],
      filePath: map['filePath'],
      uploadedBy: map['uploadedBy'],
      uploadedAt: DateTime.parse(map['uploadedAt']),
    );
  }
}
