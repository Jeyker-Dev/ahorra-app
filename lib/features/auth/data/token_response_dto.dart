import 'package:ahorra_app/features/auth/domain/auth_tokens.dart';

/// Parses the JSON payload returned by `/auth/token` and `/auth/refresh`.
AuthTokens parseTokenResponse(Map<String, dynamic> json) {
  final accessToken = json['access_token'];
  final refreshToken = json['refresh_token'];
  final tokenType = json['token_type'];
  final expiresIn = json['expires_in'];

  if (accessToken is! String ||
      accessToken.isEmpty ||
      refreshToken is! String ||
      refreshToken.isEmpty ||
      tokenType is! String ||
      expiresIn is! int) {
    throw const FormatException('Invalid token response payload.');
  }

  return AuthTokens(
    accessToken: accessToken,
    refreshToken: refreshToken,
    tokenType: tokenType,
    expiresIn: expiresIn,
  );
}
