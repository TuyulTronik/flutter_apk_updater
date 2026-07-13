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

class ApkUpdater {
  ApkUpdater({required this._config})
    : _githubApi = GitHubApi(dio: Dio()),
      _versionComparator = const VersionComparator(),
      _assetSelector = const AssetSelector(),
      _installer = const UpdateInstaller(),
      _downloadService = ApkDownloadService();

  final ApkUpdaterConfig _config;

  final GitHubApi _githubApi;

  final VersionComparator _versionComparator;

  final UpdateInstaller _installer;

  final AssetSelector _assetSelector;

  final ApkDownloadService _downloadService;

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
          message: 'Failed to check for updates.',
          exception: exception,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Result<DownloadInfo>> download({
    required UpdateInfo updateInfo,
    DownloadProgressCallback? onProgress,
  }) {
    return _downloadService.download(
      release: updateInfo.release,
      asset: updateInfo.asset,
      onProgress: onProgress,
    );
  }

  Future<Result<void>> install({required String apkPath}) {
    return _installer.install(apkPath: apkPath);
  }
}
