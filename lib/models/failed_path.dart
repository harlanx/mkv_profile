class FailedPath implements Exception {
  String reason;
  String path;

  FailedPath(
    this.reason,
    this.path,
  );
}