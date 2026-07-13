
import 'github_release.dart';

class UpdateInfo {
  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.hasUpdate,
    required this.release,
  });

  final String currentVersion;

  final String latestVersion;

  final bool hasUpdate;

  final GitHubRelease release;
}