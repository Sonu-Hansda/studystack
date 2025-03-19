import 'package:studystack/models/note.dart';

abstract class ResourceState {}

class ResourceInitial extends ResourceState {}

class ResourceLoading extends ResourceState {}

class SubjectNotesLoaded extends ResourceState {
  final List<Note> notes;

  SubjectNotesLoaded(this.notes);
}

class NoteAdded extends ResourceState {
  final Note note;

  NoteAdded(this.note);
}

class NoteDeleted extends ResourceState {
  final String noteId;

  NoteDeleted(this.noteId);
}

class ResourceError extends ResourceState {
  final String message;

  ResourceError(this.message);
}
