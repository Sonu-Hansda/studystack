abstract class ResourceEvent {}

class LoadSubjectNotesRequested extends ResourceEvent {
  final String subjectId;

  LoadSubjectNotesRequested(this.subjectId);
}

class AddNoteRequested extends ResourceEvent {
  final String subjectId;
  final String label;
  final String filePath;

  AddNoteRequested({
    required this.subjectId,
    required this.label,
    required this.filePath,
  });
}

class DeleteNoteRequested extends ResourceEvent {
  final String subjectId;
  final String noteId;

  DeleteNoteRequested({
    required this.subjectId,
    required this.noteId,
  });
}

class OpenNoteRequested extends ResourceEvent {
  final String filePath;

  OpenNoteRequested(this.filePath);
}

class AddResourceRequested extends ResourceEvent {
  final String label;
  final String filePath;

  AddResourceRequested({
    required this.label,
    required this.filePath,
  });
}

class LoadResourcesRequested extends ResourceEvent {}

class DeleteResourceRequested extends ResourceEvent {
  final String resourceId;

  DeleteResourceRequested(this.resourceId);
}
