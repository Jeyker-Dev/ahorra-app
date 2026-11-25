/// Immutable pair of OAuth2 tokens issued by `ahorra-api`.
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AuthTokens &&
            accessToken == other.accessToken &&
            refreshToken == other.refreshToken &&
            tokenType == other.tokenType &&
            expiresIn == other.expiresIn;
  }

  @override
  int get hashCode => Object.hash(accessToken, refreshToken, tokenType, expiresIn);
}
