class ScanError implements Exception {
  ScanError(
    this.reason,
    this.path,
  );

  String reason;
  String path;
}
