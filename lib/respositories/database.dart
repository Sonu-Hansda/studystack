import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studystack/models/app_user.dart';
import 'package:studystack/models/subject.dart';
import 'package:studystack/models/note.dart';

class DatabaseRepository {
  final FirebaseFirestore _firestore;

  DatabaseRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> saveUser(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      log(e.toString());
      throw Exception('Failed to create an account');
    }
  }

  Future<bool> isUserExists(String uid) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc.exists;
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> createSubject(Subject subject) async {
    await _firestore.collection('subjects').add(subject.toMap());
  }

  Future<List<Subject>> getSubjects() async {
    final querySnapshot = await _firestore.collection('subjects').get();
    return querySnapshot.docs
        .map((doc) => Subject.fromMap(doc.data()))
        .toList();
  }

  Future<void> createNote(String subjectId, Note note) async {
    await _firestore
        .collection('subjects')
        .doc(subjectId)
        .collection('notes')
        .add(note.toMap());
  }

  Future<List<Note>> getNotesForSubject(String subjectId) async {
    final querySnapshot = await _firestore
        .collection('subjects')
        .doc(subjectId)
        .collection('notes')
        .get();
    return querySnapshot.docs.map((doc) => Note.fromMap(doc.data())).toList();
  }
}
