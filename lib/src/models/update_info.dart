import 'github_asset.dart';
import 'github_release.dart';

class UpdateInfo {
  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.hasUpdate,
    required this.release,
    required this.asset,
  });

  final String currentVersion;

  final String latestVersion;

  final bool hasUpdate;

  final GitHubRelease release;
  final GitHubAsset asset;
}
