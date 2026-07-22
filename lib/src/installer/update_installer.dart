import 'dart:io';

import '../../flutter_apk_updater.dart';

/// Service untuk menginstall APK.
class UpdateInstaller {
  const UpdateInstaller();

  /// Install APK dari path yang diberikan.
  ///
  /// [apkPath] Path absolut ke file APK.
  /// [autoDelete] Jika true, file APK akan dihapus setelah install.
  ///
  /// Returns:
  /// - `Success<void>` jika installasi berhasil dimulai
  /// - `Error<Failure>` jika terjadi error
  Future<Result<void>> install({
    required String apkPath,
    bool autoDelete = false,
    bool closeAppAfterInstall = true,
  }) async {
    // 1. Cek apakah file ada
    final file = File(apkPath);
    if (!await file.exists()) {
      return Error(
        Failure(
          code: 'install.file_not_found',
          message: 'File APK tidak ditemukan: $apkPath',
        ),
      );
    }

    // 2. Cek permission sebelum install
    final hasPermission = await FlutterApkUpdaterPlatform.instance
        .canRequestPackageInstalls();

    if (!hasPermission) {
      return Error(
        Failure(
          code: 'permission_denied',
          message:
              'Mohon izinkan instalasi dari sumber tidak dikenal.\n'
              'Buka Settings > Apps > Special app access > Install unknown apps',
        ),
      );
    }

    // 3. Install APK
    final result = await FlutterApkUpdaterPlatform.instance.install(
      apkPath: apkPath,
    );

    // 4. Hapus file jika autoDelete = true dan install berhasil
    if (result.isSuccess && autoDelete) {
      try {
        await file.delete();
      } catch (_) {
        // Abaikan error saat delete, tidak mempengaruhi install
      }
    }
    // 5. CLOSE APP jika sukses dan flag diaktifkan
    if (result.isSuccess && closeAppAfterInstall) {
      await FlutterApkUpdaterPlatform.instance.closeApp();
    }
    return result;
  }

  /// Buka halaman settings untuk izin install.
  Future<bool> openInstallSettings() {
    return FlutterApkUpdaterPlatform.instance.openInstallSettings();
  }

  /// Cek apakah memiliki izin install.
  Future<bool> canRequestPackageInstalls() {
    return FlutterApkUpdaterPlatform.instance.canRequestPackageInstalls();
  }
}
