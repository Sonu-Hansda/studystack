class Note {
  final String label;
  final String url;

  Note({
    required this.label,
    required this.url,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'url': url,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      label: map['label'],
      url: map['url'],
    );
  }
}
