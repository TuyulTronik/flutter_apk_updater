import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../api/github_api.dart';
import '../config/apk_updater_config.dart';
import '../downloader/apk_downloader.dart';
import '../installer/update_installer.dart';
import '../models/download_info.dart';
import '../models/failure.dart';
import '../models/github_asset.dart';
import '../models/github_release.dart';
import '../models/result.dart';
import '../models/update_info.dart';
import '../version/version_comparator.dart';
import 'asset_selector.dart';

/// Main class untuk melakukan update APK dari GitHub Releases.
///
/// Contoh penggunaan:
/// ```dart
/// final updater = ApkUpdater(
///   config: ApkUpdaterConfig(
///     owner: 'TuyulTronik',
///     repository: 'my_app',
///     apkPattern: 'app-release',
///     verifyChecksum: true,
///     autoDeleteAfterInstall: false,
///   ),
///   timeout: Duration(seconds: 60),
/// );
/// ```
class ApkUpdater {
  ApkUpdater({
    required this._config,
    GitHubApi? githubApi,
    VersionComparator? versionComparator,
    AssetSelector? assetSelector,
    UpdateInstaller? installer,
    ApkDownloadService? downloadService,
    this.timeout = const Duration(seconds: 60),
  }) : _githubApi =
           githubApi ??
           GitHubApi(
             dio: Dio(
               BaseOptions(
                 connectTimeout: timeout,
                 receiveTimeout: timeout,
                 sendTimeout: timeout,
               ),
             ),
           ),
       _versionComparator = versionComparator ?? const VersionComparator(),
       _assetSelector = assetSelector ?? const AssetSelector(),
       _installer = installer ?? const UpdateInstaller(),
       _downloadService = downloadService ?? ApkDownloadService();

  final ApkUpdaterConfig _config;
  final GitHubApi _githubApi;
  final VersionComparator _versionComparator;
  final UpdateInstaller _installer;
  final AssetSelector _assetSelector;
  final ApkDownloadService _downloadService;
  final Duration timeout;

  /// Cek apakah ada update baru.
  ///
  /// Returns:
  /// - `Success<UpdateInfo>` dengan info update
  /// - `Error<Failure>` jika terjadi error
  Future<Result<UpdateInfo>> check() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final releaseResult = await _githubApi.getLatestRelease(config: _config);

      if (releaseResult is Error<GitHubRelease>) {
        return Error(releaseResult.failure);
      }

      final release = (releaseResult as Success<GitHubRelease>).data;

      final compareResult = _versionComparator.hasUpdate(
        currentVersion: currentVersion,
        latestVersion: release.version,
      );

      if (compareResult is Error<bool>) {
        return Error(compareResult.failure);
      }

      final hasUpdate = (compareResult as Success<bool>).data;

      final assetResult = _assetSelector.select(
        release: release,
        apkPattern: _config.apkPattern,
      );

      if (assetResult is Error<GitHubAsset>) {
        return Error(assetResult.failure);
      }

      final selectedAsset = (assetResult as Success<GitHubAsset>).data;

      return Success(
        UpdateInfo(
          currentVersion: currentVersion,
          latestVersion: release.version,
          hasUpdate: hasUpdate,
          release: release,
          asset: selectedAsset,
        ),
      );
    } catch (exception, stackTrace) {
      return Error(
        Failure(
          code: 'updater.check_failed',
          message: 'Gagal mengecek update.',
          exception: exception,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Download APK dari GitHub Release.
  ///
  /// [updateInfo] Info update dari [check()].
  /// [onProgress] Callback untuk progress download.
  ///
  /// Returns:
  /// - `Success<DownloadInfo>` dengan info file APK
  /// - `Error<Failure>` jika terjadi error
  Future<Result<DownloadInfo>> download({
    required UpdateInfo updateInfo,
    DownloadProgressCallback? onProgress,
  }) {
    return _downloadService.download(
      release: updateInfo.release,
      asset: updateInfo.asset,
      config: _config,
      onProgress: onProgress,
    );
  }

  /// Install APK yang sudah didownload.
  ///
  /// [apkPath] Path ke file APK.
  ///
  /// Returns:
  /// - `Success<void>` jika installasi berhasil dimulai
  /// - `Error<Failure>` jika terjadi error
  Future<Result<void>> install({required String apkPath}) {
    return _installer.install(
      apkPath: apkPath,
      autoDelete: _config.autoDeleteAfterInstall,
      closeAppAfterInstall: _config.closeAppAfterInstall,
    );
  }

  /// Buka halaman settings untuk izin install.
  Future<bool> openInstallSettings() {
    return _installer.openInstallSettings();
  }

  /// Cek apakah memiliki izin install.
  Future<bool> canRequestPackageInstalls() {
    return _installer.canRequestPackageInstalls();
  }

  /// Batalkan download yang sedang berjalan.
  void cancelDownload() {
    _downloadService.cancel();
  }
}
