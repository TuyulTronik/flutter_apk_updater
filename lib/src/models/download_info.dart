class DownloadInfo {
  const DownloadInfo({
    required this.receivedBytes,
    required this.totalBytes,
    required this.localFilePath,
  });

  /// Downloaded bytes.
  final int receivedBytes;

  /// Total file size.
  final int totalBytes;

  /// Downloaded apk location.
  final String localFilePath;

  /// Download percentage (0.0 - 1.0).
  double get progress {
    if (totalBytes <= 0) {
      return 0;
    }

    return receivedBytes / totalBytes;
  }

  /// Download completed.
  bool get isCompleted {
    return totalBytes > 0 && receivedBytes >= totalBytes;
  }
}