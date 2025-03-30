import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:studystack/enums/message_type.dart';
import 'package:studystack/models/app_user.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {
  final firebase_auth.User user;
  final AppUser appUser;

  const AuthenticationAuthenticated({
    required this.user,
    required this.appUser,
  });

  @override
  List<Object?> get props => [user, appUser];
}

class AuthenticationUnauthenticated extends AuthenticationState {}

class AuthenticationError extends AuthenticationState {
  final String message;
  const AuthenticationError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthenticationMessage extends AuthenticationState {
  final String message;
  final MessageType type;

  const AuthenticationMessage({
    required this.message,
    required this.type,
  });

  @override
  List<Object?> get props => [message, type];
}
