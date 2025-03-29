import 'package:equatable/equatable.dart';
import 'package:studystack/models/note.dart';
import 'package:studystack/models/subject.dart';

abstract class SubjectsNotesState extends Equatable {
  const SubjectsNotesState();

  @override
  List<Object> get props => [];
}

class SubjectsNotesInitial extends SubjectsNotesState {}

class SubjectsLoading extends SubjectsNotesState {}

class SubjectsLoaded extends SubjectsNotesState {
  final List<Subject> subjects;

  const SubjectsLoaded(this.subjects);

  @override
  List<Object> get props => [subjects];
}

class NotesLoading extends SubjectsNotesState {
  final String subjectId;

  const NotesLoading(this.subjectId);

  @override
  List<Object> get props => [subjectId];
}

class NotesLoaded extends SubjectsNotesState {
  final List<Note> notes;
  final String subjectId;

  const NotesLoaded(this.notes, this.subjectId);

  @override
  List<Object> get props => [notes, subjectId];
}

class OperationSuccess extends SubjectsNotesState {
  final String message;

  const OperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class OperationError extends SubjectsNotesState {
  final String error;

  const OperationError(this.error);

  @override
  List<Object> get props => [error];
}
