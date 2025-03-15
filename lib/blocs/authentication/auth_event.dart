import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthenticationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthenticationUserChanged extends AuthenticationEvent {
  final User? user;

  AuthenticationUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthenticationLogoutRequested extends AuthenticationEvent {}

class AuthenticationGoogleSignInRequested extends AuthenticationEvent {}

class AuthenticationRegisterRequested extends AuthenticationEvent {
  final String email;
  final String password;
  final String fullname;

  AuthenticationRegisterRequested({
    required this.fullname,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [fullname, email, password];
}

class AuthenticationLoginRequested extends AuthenticationEvent {
  final String email;
  final String password;

  AuthenticationLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}
