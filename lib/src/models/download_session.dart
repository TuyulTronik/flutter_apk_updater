class DownloadSession {
  const DownloadSession({
    required this.version,
    required this.downloadUrl,
    required this.filePath,
    required this.totalBytes,
    required this.downloadedBytes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DownloadSession.fromJson(
    Map<String, dynamic> json,
  ) {
    return DownloadSession(
      version: json['version'] as String,
      downloadUrl: json['downloadUrl'] as String,
      filePath: json['filePath'] as String,
      totalBytes: json['totalBytes'] as int,
      downloadedBytes: json['downloadedBytes'] as int,
      createdAt: DateTime.parse(
        json['createdAt'] as String,
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] as String,
      ),
    );
  }

  final String version;

  final String downloadUrl;

  final String filePath;

  final int totalBytes;

  final int downloadedBytes;

  final DateTime createdAt;

  final DateTime updatedAt;

  bool get isCompleted =>
      downloadedBytes >= totalBytes;

  double get progress {
    if (totalBytes == 0) {
      return 0;
    }

    return downloadedBytes / totalBytes;
  }

  DownloadSession copyWith({
    String? version,
    String? downloadUrl,
    String? filePath,
    int? totalBytes,
    int? downloadedBytes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DownloadSession(
      version: version ?? this.version,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      filePath: filePath ?? this.filePath,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes:
          downloadedBytes ?? this.downloadedBytes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'downloadUrl': downloadUrl,
      'filePath': filePath,
      'totalBytes': totalBytes,
      'downloadedBytes': downloadedBytes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}