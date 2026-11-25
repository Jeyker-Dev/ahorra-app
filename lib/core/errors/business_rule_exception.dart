/// Base class for expected domain or business-rule exceptions.
abstract class BusinessRuleException implements Exception {
  const BusinessRuleException(this.message);

  /// User-facing explanation of the broken rule.
  final String message;

  @override
  String toString() => message;
}
