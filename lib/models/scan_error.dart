class ScanError implements Exception {
  String reason;
  String path;

  ScanError(
    this.reason,
    this.path,
  );
}
