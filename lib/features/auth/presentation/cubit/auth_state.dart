import '../../data/models/user_model.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  final bool isNewUser;
  const AuthAuthenticated(this.user, {this.isNewUser = false});
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthGuest extends AuthState {
  const AuthGuest();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class AuthResetPasswordSuccess extends AuthState {
  const AuthResetPasswordSuccess();
}
