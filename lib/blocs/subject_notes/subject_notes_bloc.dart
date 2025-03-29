import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studystack/blocs/subject_notes/subject_notes_event.dart';
import 'package:studystack/blocs/subject_notes/subject_notes_state.dart';
import 'package:studystack/models/subject.dart';
import 'package:studystack/models/note.dart';

class SubjectsNotesBloc extends Bloc<SubjectsNotesEvent, SubjectsNotesState> {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  SubjectsNotesBloc({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        super(SubjectsNotesInitial()) {
    on<LoadSubjects>(_onLoadSubjects);
    on<AddSubject>(_onAddSubject);
    on<UpdateSubject>(_onUpdateSubject);
    on<DeleteSubject>(_onDeleteSubject);
    on<LoadNotes>(_onLoadNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
  }

  Future<void> _onLoadSubjects(
    LoadSubjects event,
    Emitter<SubjectsNotesState> emit,
  ) async {
    emit(SubjectsLoading());
    try {
      Query query = _firestore.collection('subjects');

      if (event.branchFilter != null) {
        query = query.where('branchCode', isEqualTo: event.branchFilter);
      }

      final snapshot = await query.get();
      final subjects = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Subject.fromMap(data..['id'] = doc.id);
      }).toList();
      emit(SubjectsLoaded(subjects));
    } catch (e) {
      emit(OperationError('Failed to load subjects: ${e.toString()}'));
    }
  }

  Future<void> _onAddSubject(
    AddSubject event,
    Emitter<SubjectsNotesState> emit,
  ) async {
    try {
      await _firestore.collection('subjects').add(event.subject.toMap());
      emit(OperationSuccess('Subject added successfully'));
    } catch (e) {
      emit(OperationError('Failed to add subject: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateSubject(
    UpdateSubject event,
    Emitter<SubjectsNotesState> emit,
  ) async {
    try {
      await _firestore
          .collection('subjects')
          .doc(event.subject.id)
          .update(event.subject.toMap());
      emit(OperationSuccess('Subject updated successfully'));
    } catch (e) {
      emit(OperationError('Failed to update subject: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteSubject(
    DeleteSubject event,
    Emitter<SubjectsNotesState> emit,
  ) async {
    try {
      // First delete all notes in this subject
      final notesSnapshot = await _firestore
          .collection('subjects')
          .doc(event.subjectId)
          .collection('notes')
          .get();

      final batch = _firestore.batch();
      for (final doc in notesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Then delete the subject
      await _firestore.collection('subjects').doc(event.subjectId).delete();

      emit(OperationSuccess('Subject deleted successfully'));
    } catch (e) {
      emit(OperationError('Failed to delete subject: ${e.toString()}'));
    }
  }

  Future<void> _onLoadNotes(
    LoadNotes event,
    Emitter<SubjectsNotesState> emit,
  ) async {
    emit(NotesLoading(event.subjectId));
    try {
      final snapshot = await _firestore
          .collection('subjects')
          .doc(event.subjectId)
          .collection('notes')
          .orderBy('uploadedAt', descending: true)
          .get();

      final notes = snapshot.docs
          .map((doc) => Note.fromMap(doc.data()..['id'] = doc.id))
          .toList();

      emit(NotesLoaded(notes, event.subjectId));
    } catch (e) {
      emit(OperationError('Failed to load notes: ${e.toString()}'));
    }
  }

  Future<void> _onAddNote(
    AddNote event,
    Emitter<SubjectsNotesState> emit,
  ) async {
    try {
      String? fileUrl;

      // Upload file if provided
      if (event.file != null) {
        final ref = _storage.ref().child(
            'notes/${event.subjectId}/${DateTime.now().millisecondsSinceEpoch}');
        await ref.putFile(event.file!);
        fileUrl = await ref.getDownloadURL();
      }

      // Create note with file URL
      final note = event.note.copyWith(
        filePath: fileUrl ?? event.note.filePath,
      );

      await _firestore
          .collection('subjects')
          .doc(event.subjectId)
          .collection('notes')
          .add(note.toMap());

      emit(OperationSuccess('Note added successfully'));
    } catch (e) {
      emit(OperationError('Failed to add note: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateNote(
    UpdateNote event,
    Emitter<SubjectsNotesState> emit,
  ) async {
    try {
      String? fileUrl = event.note.filePath;

      // Upload new file if provided
      if (event.file != null) {
        // Delete old file if exists
        await _storage.refFromURL(event.note.filePath).delete();

        final ref = _storage.ref().child(
            'notes/${event.subjectId}/${DateTime.now().millisecondsSinceEpoch}');
        await ref.putFile(event.file!);
        fileUrl = await ref.getDownloadURL();
      }

      // Update note with new file URL
      final updatedNote = event.note.copyWith(
        filePath: fileUrl,
      );

      await _firestore
          .collection('subjects')
          .doc(event.subjectId)
          .collection('notes')
          .doc(updatedNote.id)
          .update(updatedNote.toMap());

      emit(OperationSuccess('Note updated successfully'));
    } catch (e) {
      emit(OperationError('Failed to update note: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteNote(
    DeleteNote event,
    Emitter<SubjectsNotesState> emit,
  ) async {
    try {
      // Delete file from storage if requested
      if (event.deleteFile) {
        final doc = await _firestore
            .collection('subjects')
            .doc(event.subjectId)
            .collection('notes')
            .doc(event.noteId)
            .get();

        if (doc.exists) {
          final note = Note.fromMap(doc.data()!);
          await _storage.refFromURL(note.filePath).delete();
        }
      }

      // Delete note document
      await _firestore
          .collection('subjects')
          .doc(event.subjectId)
          .collection('notes')
          .doc(event.noteId)
          .delete();

      emit(OperationSuccess('Note deleted successfully'));
    } catch (e) {
      emit(OperationError('Failed to delete note: ${e.toString()}'));
    }
  }
}
