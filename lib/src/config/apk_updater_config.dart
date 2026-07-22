/// Konfigurasi untuk APK Updater.
///
/// Contoh penggunaan:
/// ```dart
/// final config = ApkUpdaterConfig(
///   owner: 'TuyulTronik',
///   repository: 'my_app',
///   apkPattern: 'app-release',
///   githubToken: 'your_token', // Opsional
///   verifyChecksum: true,      // Opsional, default false
///   autoDeleteAfterInstall: false, // Opsional, default false
/// );
/// ```
class ApkUpdaterConfig {
  const ApkUpdaterConfig({
    required this.owner,
    required this.repository,
    required this.apkPattern,
    this.githubToken,
    this.tokenProvider,
    this.verifyChecksum = false,
    this.autoDeleteAfterInstall = false,
    this.closeAppAfterInstall = true,
  });

  /// GitHub owner (username atau organisasi)
  final String owner;

  /// Nama repository GitHub
  final String repository;

  /// Pattern untuk memilih asset APK (case-insensitive)
  /// Contoh: 'app-release' akan match dengan 'app-release.apk'
  final String apkPattern;

  /// [DEPRECATED] Gunakan [tokenProvider] untuk keamanan lebih baik.
  /// Token GitHub untuk akses private repository.
  @Deprecated(
    'Gunakan tokenProvider untuk keamanan lebih baik. '
    'Contoh: tokenProvider: () async => await secureStorage.read(key: "github_token")',
  )
  final String? githubToken;

  /// Provider untuk mendapatkan token GitHub secara dinamis.
  /// Berguna untuk menyimpan token di secure storage.
  ///
  /// Contoh:
  /// ```dart
  /// tokenProvider: () async {
  ///   final storage = FlutterSecureStorage();
  ///   return await storage.read(key: 'github_token');
  /// }
  /// ```
  final Future<String?> Function()? tokenProvider;

  /// Apakah perlu verifikasi checksum SHA256.
  /// Jika true, package akan mencari file `{apk_name}.apk.sha256`
  /// di GitHub Release dan memverifikasi integritas APK.
  ///
  /// Default: false (tidak wajib)
  final bool verifyChecksum;

  /// Apakah otomatis menghapus file APK setelah install.
  /// Jika false, file tetap tersimpan dan akan di-overwrite
  /// pada download berikutnya.
  ///
  /// Default: false (file tetap ada)
  final bool autoDeleteAfterInstall;

  // Apakah app otomatis ditutup setelah install APK.
  /// Default: true (untuk mencegah duplicate instance)
  final bool closeAppAfterInstall;

  /// Mendapatkan token dengan prioritas:
  /// 1. tokenProvider (jika ada)
  /// 2. githubToken (jika ada, deprecated)
  /// 3. null
  Future<String?> getToken() async {
    if (tokenProvider != null) {
      return await tokenProvider!();
    }
    return githubToken;
  }

  /// Copy dengan perubahan field tertentu.
  ApkUpdaterConfig copyWith({
    String? owner,
    String? repository,
    String? apkPattern,
    String? githubToken,
    Future<String?> Function()? tokenProvider,
    bool? verifyChecksum,
    bool? autoDeleteAfterInstall,
  }) {
    return ApkUpdaterConfig(
      owner: owner ?? this.owner,
      repository: repository ?? this.repository,
      apkPattern: apkPattern ?? this.apkPattern,
      githubToken: githubToken ?? this.githubToken,
      tokenProvider: tokenProvider ?? this.tokenProvider,
      verifyChecksum: verifyChecksum ?? this.verifyChecksum,
      autoDeleteAfterInstall:
          autoDeleteAfterInstall ?? this.autoDeleteAfterInstall,
    );
  }
}
