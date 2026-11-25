/// Narrow contract used by `core/network` to attach and refresh Bearer tokens
/// without depending on `features/auth`.
abstract interface class AuthTokenDelegate {
  /// Returns the current access token, or `null` if unauthenticated.
  Future<String?> readAccessToken();

  /// Refreshes the token pair and returns the new access token, or `null` if
  /// no refresh token is available.
  ///
  /// Throws [RefreshUnauthorizedException] when the server rejects the refresh
  /// token (e.g. HTTP 401). Network errors propagate without clearing tokens.
  Future<String?> refreshAccessToken();

  /// Clears stored tokens and notifies the session layer that authentication was lost.
  Future<void> onSessionExpired();
}

/// Signals that `/auth/refresh` returned 401/403 (invalid or reused refresh token).
final class RefreshUnauthorizedException implements Exception {
  const RefreshUnauthorizedException();
}
