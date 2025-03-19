import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:studystack/models/app_user.dart';
import 'package:studystack/respositories/database.dart';

class AuthenticationRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final DatabaseRepository _databaseRepository;

  AuthenticationRepository(
      {FirebaseAuth? firebaseAuth, DatabaseRepository? databaseRepository})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = GoogleSignIn(),
        _databaseRepository = databaseRepository ?? DatabaseRepository();

  Stream<User?> get userChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<AppUser?> getCurrentAppUser() async {
    final user = currentUser;
    if (user != null) {
      return await _databaseRepository.getUser(user.uid);
    }
    return null;
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        log('Google sign in aborted by user');
        return;
      }
      final email = googleUser.email;
      if (!email.endsWith('@nitjsr.ac.in')) {
        throw Exception('Please use your college email to sign in.');
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final bool userExists =
            await _databaseRepository.isUserExists(firebaseUser.uid);
        if (!userExists) {
          final AppUser newUser = AppUser(
            uid: firebaseUser.uid,
            fullName: firebaseUser.displayName ?? 'Google User',
            email: firebaseUser.email ?? '',
          );
          await _databaseRepository.saveUser(newUser);
          log('User created in database: ${firebaseUser.email}');
        }
      }
    } catch (e) {
      log('Error signing in with Google: $e');
    }
  }

  Future<void> createAccount({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser != null) {
        final AppUser userModel = AppUser(
          uid: firebaseUser.uid,
          fullName: fullName,
          email: email,
        );
        await _databaseRepository.saveUser(userModel);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              'The email address is already in use by another account.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'weak-password':
          errorMessage =
              'The password is too weak. Please use a stronger password.';
          break;
        case 'network-request-failed':
          errorMessage =
              'Network error. Please check your internet connection.';
          break;
        default:
          errorMessage = e.message ?? 'An unknown error occurred.';
      }
      throw FirebaseAuthException(message: errorMessage, code: e.code);
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      log('Error during sign out: $e');
    }
  }
}
