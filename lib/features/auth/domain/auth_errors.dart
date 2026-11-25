import 'package:ahorra_app/core/errors/business_rule_exception.dart';

/// Thrown when `/auth/token` rejects the user's email or password.
final class InvalidCredentialsException extends BusinessRuleException {
  const InvalidCredentialsException() : super('Wrong email or password.');
}

/// Thrown when an auth request cannot reach the server.
final class AuthNetworkException extends BusinessRuleException {
  const AuthNetworkException() : super('No connection. Try again.');
}

/// Thrown when the refresh token is rejected or missing and re-authentication is required.
final class SessionExpiredException extends BusinessRuleException {
  const SessionExpiredException() : super('Session expired. Sign in again.');
}
