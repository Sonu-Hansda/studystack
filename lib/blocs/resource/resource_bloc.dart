import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:studystack/blocs/resource/resource_event.dart';
import 'package:studystack/blocs/resource/resource_state.dart';
import 'package:studystack/models/note.dart';

class ResourceBloc extends Bloc<ResourceEvent, ResourceState> {
  final String _notesDir = 'notes';

  ResourceBloc() : super(ResourceInitial()) {
    on<LoadSubjectNotesRequested>(_onLoadSubjectNotesRequested);
    on<AddNoteRequested>(_onAddNoteRequested);
    on<DeleteNoteRequested>(_onDeleteNoteRequested);
    on<OpenNoteRequested>(_onOpenNoteRequested);
  }

  Future<void> _onLoadSubjectNotesRequested(
    LoadSubjectNotesRequested event,
    Emitter<ResourceState> emit,
  ) async {
    try {
      emit(ResourceLoading());

      final subjectDir = Directory('$_notesDir/${event.subjectId}');
      if (!await subjectDir.exists()) {
        emit(SubjectNotesLoaded([]));
        return;
      }

      // TODO: Implement loading notes from storage
      // For now, return empty list
      emit(SubjectNotesLoaded([]));
    } catch (e) {
      emit(ResourceError(e.toString()));
    }
  }

  Future<void> _onAddNoteRequested(
    AddNoteRequested event,
    Emitter<ResourceState> emit,
  ) async {
    try {
      emit(ResourceLoading());

      // Create subject directory if it doesn't exist
      final subjectDir = Directory('$_notesDir/${event.subjectId}');
      if (!await subjectDir.exists()) {
        await subjectDir.create(recursive: true);
      }

      // Generate unique filename
      final id = const Uuid().v4();
      final extension = event.filePath.split('.').last;
      final fileName = '$id.$extension';
      final filePath = '${subjectDir.path}/$fileName';

      // Copy the file to the subject directory
      await File(event.filePath).copy(filePath);

      // Create note object
      final note = Note(
        label: event.label,
        filePath: filePath,
        uploadedBy: 'user_id', // TODO: Get actual user ID
        uploadedAt: DateTime.now(),
      );

      emit(NoteAdded(note));
    } catch (e) {
      emit(ResourceError(e.toString()));
    }
  }

  Future<void> _onDeleteNoteRequested(
    DeleteNoteRequested event,
    Emitter<ResourceState> emit,
  ) async {
    try {
      emit(ResourceLoading());

      // TODO: Implement deleting note from storage
      // For now, just emit the deleted state
      emit(NoteDeleted(event.noteId));
    } catch (e) {
      emit(ResourceError(e.toString()));
    }
  }

  Future<void> _onOpenNoteRequested(
    OpenNoteRequested event,
    Emitter<ResourceState> emit,
  ) async {
    try {
      final file = File(event.filePath);
      if (!await file.exists()) {
        emit(ResourceError('Note file not found'));
        return;
      }

      // TODO: Implement opening PDF file
      // This will be handled by the UI layer using a PDF viewer
      emit(ResourceInitial());
    } catch (e) {
      emit(ResourceError(e.toString()));
    }
  }
}
