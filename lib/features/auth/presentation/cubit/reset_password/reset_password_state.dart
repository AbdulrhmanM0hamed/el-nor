abstract class ResetPasswordState {
  const ResetPasswordState();
}

class ResetPasswordInitial extends ResetPasswordState {
  const ResetPasswordInitial();
}

class ResetPasswordLoading extends ResetPasswordState {
  const ResetPasswordLoading();
}

class ResetCodeSent extends ResetPasswordState {
  final String message;
  const ResetCodeSent(this.message);
}

class CodeVerified extends ResetPasswordState {
  final String message;
  const CodeVerified(this.message);
}

class PasswordResetSuccess extends ResetPasswordState {
  final String message;
  const PasswordResetSuccess(this.message);
}

class ResetPasswordError extends ResetPasswordState {
  final String message;
  const ResetPasswordError(this.message);
} 