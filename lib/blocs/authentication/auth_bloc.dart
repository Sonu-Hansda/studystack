import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studystack/blocs/authentication/auth_event.dart';
import 'package:studystack/blocs/authentication/auth_state.dart';
import 'package:studystack/respositories/authentication.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository _authenticationRepository;
  late final Stream<User?> _userStream;

  AuthenticationBloc(
      {required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(
          authenticationRepository.currentUser != null
              ? AuthenticationAuthenticated(
                  user: authenticationRepository.currentUser!)
              : AuthenticationUnauthenticated(),
        ) {
    _userStream = _authenticationRepository.userChanges;
    on<AuthenticationUserChanged>(_onUserChanged);
    on<AuthenticationLogoutRequested>(_onLogoutRequested);
    on<AuthenticationLoginRequested>(_onLoginRequested);
    on<AuthenticationRegisterRequested>(_onRegisterRequested);
    on<AuthenticationGoogleSignInRequested>(_onGoogleSignIn);
    _userStream.listen((user) => add(AuthenticationUserChanged(user)));
  }

  void _onUserChanged(
      AuthenticationUserChanged event, Emitter<AuthenticationState> emit) {
    if (event.user != null) {
      emit(AuthenticationAuthenticated(user: event.user!));
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
      emit(AuthenticationFailure(error: errorMessage));
    }
  }

  Future<void> _onGoogleSignIn(AuthenticationGoogleSignInRequested event,
      Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      await _authenticationRepository.signInWithGoogle();
    } catch (error) {
      String errorMessage = 'Authentication failed. Please try again.';
      emit(AuthenticationFailure(error: errorMessage));
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
      emit(AuthenticationFailure(error: errorMessage));
    }
  }
}
