class Failure {
  const Failure({
    required this.code,
    required this.message,
    this.exception,
    this.stackTrace,
  });

  final String code;

  final String message;

  final Object? exception;

  final StackTrace? stackTrace;
}