class GitHubAsset {
  const GitHubAsset({
    required this.name,
    required this.downloadUrl,
    required this.size,
    this.checksumUrl,
  });

  factory GitHubAsset.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final downloadUrl = json['browser_download_url'] as String;

    // Generate checksum URL jika ada file .sha256
    String? checksumUrl;
    if (name.endsWith('.sha256')) {
      checksumUrl = downloadUrl;
    }

    return GitHubAsset(
      name: name,
      downloadUrl: downloadUrl,
      size: (json['size'] as num).toInt(),
      checksumUrl: checksumUrl,
    );
  }

  /// Nama file asset
  final String name;

  /// URL untuk download asset
  final String downloadUrl;

  /// Ukuran file dalam bytes
  final int size;

  /// URL untuk download file checksum (SHA256)
  /// Format: {apk_name}.apk.sha256
  final String? checksumUrl;

  /// Mendapatkan nama file APK tanpa ekstensi .sha256
  String get apkName {
    if (name.endsWith('.sha256')) {
      return name.substring(0, name.length - 7); // hapus '.sha256'
    }
    return name;
  }

  /// Cek apakah ini file checksum
  bool get isChecksumFile => name.endsWith('.sha256');

  /// Cek apakah ini file APK
  bool get isApkFile => name.endsWith('.apk');
}