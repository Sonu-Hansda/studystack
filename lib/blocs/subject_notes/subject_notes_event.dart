import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:studystack/models/note.dart';
import 'package:studystack/models/subject.dart';

abstract class SubjectsNotesEvent extends Equatable {
  const SubjectsNotesEvent();

  @override
  List<Object> get props => [];
}

class LoadSubjects extends SubjectsNotesEvent {
  final String? branchFilter;

  const LoadSubjects({this.branchFilter});
}

class AddSubject extends SubjectsNotesEvent {
  final Subject subject;

  const AddSubject(this.subject);
}

class UpdateSubject extends SubjectsNotesEvent {
  final Subject subject;

  const UpdateSubject(this.subject);
}

class DeleteSubject extends SubjectsNotesEvent {
  final String subjectId;

  const DeleteSubject(this.subjectId);
}

class LoadNotes extends SubjectsNotesEvent {
  final String subjectId;

  const LoadNotes(this.subjectId);
}

class AddNote extends SubjectsNotesEvent {
  final Note note;
  final String subjectId;
  final File? file;
  const AddNote(this.note, this.subjectId, {this.file});
}

class UpdateNote extends SubjectsNotesEvent {
  final Note note;
  final String subjectId;
  final File? file;

  const UpdateNote(this.note, this.subjectId, {this.file});
}

class DeleteNote extends SubjectsNotesEvent {
  final String noteId;
  final String subjectId;
  final bool deleteFile;

  const DeleteNote(this.noteId, this.subjectId, {this.deleteFile = true});
}
