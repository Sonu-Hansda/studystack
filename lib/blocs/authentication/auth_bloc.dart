import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studystack/blocs/authentication/auth_event.dart';
import 'package:studystack/blocs/authentication/auth_state.dart';
import 'package:studystack/enums/message_type.dart';
import 'package:studystack/repositories/authentication.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository _authenticationRepository;
  late final Stream<User?> _userStream;

  AuthenticationBloc(
      {required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(AuthenticationInitial()) {
    _userStream = _authenticationRepository.userChanges;
    on<AuthenticationUserChanged>(_onUserChanged);
    on<AuthenticationLogoutRequested>(_onLogoutRequested);
    on<AuthenticationLoginRequested>(_onLoginRequested);
    on<AuthenticationRegisterRequested>(_onRegisterRequested);
    on<AuthenticationGoogleSignInRequested>(_onGoogleSignIn);
    _userStream.listen((user) => add(AuthenticationUserChanged(user)));
  }

  Future<void> _onUserChanged(AuthenticationUserChanged event,
      Emitter<AuthenticationState> emit) async {
    final user = event.user;

    if (user != null) {
      if (!user.emailVerified) {
        await user.sendEmailVerification();

        emit(AuthenticationMessage(
          message:
              'A verification email has been sent to your email address. Please verify your email to continue.',
          type: MessageType.normal,
        ));
        await _authenticationRepository.signOut();
        emit(AuthenticationUnauthenticated());
        return;
      }

      final appUser = await _authenticationRepository.getCurrentAppUser();
      if (appUser != null) {
        emit(AuthenticationAuthenticated(user: user, appUser: appUser));
      } else {
        emit(AuthenticationMessage(
          message: 'Failed to load user data. Please try again.',
          type: MessageType.error,
        ));
        await _authenticationRepository.signOut();
        emit(AuthenticationUnauthenticated());
      }
    } else {
      emit(AuthenticationUnauthenticated());
    }
  }

  void _onLogoutRequested(AuthenticationLogoutRequested event,
      Emitter<AuthenticationState> emit) async {
    await _authenticationRepository.signOut();
  }

  Future<void> _onLoginRequested(AuthenticationLoginRequested event,
      Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      await _authenticationRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
    } catch (error) {
      String errorMessage = 'Authentication failed. Please try again.';
      if (error is FirebaseAuthException) {
        switch (error.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email address.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password provided.';
            break;
          case 'invalid-credential':
            errorMessage = 'Incorrect email or password';
            break;
          case 'network-request-failed':
            errorMessage =
                'Network error. Please check your internet connection.';
            break;
          default:
            errorMessage = error.message ?? errorMessage;
        }
      }
      emit(AuthenticationMessage(
          message: errorMessage, type: MessageType.error));
    }
  }

  Future<void> _onGoogleSignIn(AuthenticationGoogleSignInRequested event,
      Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      await _authenticationRepository.signInWithGoogle();
    } catch (error) {
      String errorMessage = 'Authentication failed. Please try again.';
      emit(AuthenticationMessage(
          message: errorMessage, type: MessageType.error));
    }
  }

  Future<void> _onRegisterRequested(AuthenticationRegisterRequested event,
      Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      await _authenticationRepository.createAccount(
        fullName: event.fullname,
        email: event.email,
        password: event.password,
      );
    } catch (error) {
      String errorMessage = 'Registeration Failed. Please try again';
      if (error is FirebaseAuthException) {
        errorMessage = error.message ?? errorMessage;
      }
      emit(AuthenticationMessage(
          message: errorMessage, type: MessageType.error));
    }
  }
}
