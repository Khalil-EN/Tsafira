class PremiumRequiredException implements Exception {
  final String message;
  PremiumRequiredException([this.message = "Premium subscription required."]);

  @override
  String toString() => "PremiumRequiredException: $message";
}
