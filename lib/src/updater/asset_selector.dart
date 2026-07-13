import '../models/failure.dart';
import '../models/github_asset.dart';
import '../models/github_release.dart';
import '../models/result.dart';

class AssetSelector {
  const AssetSelector();

  Result<GitHubAsset> select({
    required GitHubRelease release,
    required String apkPattern,
  }) {
    if (release.assets.isEmpty) {
      return const Error(
        Failure(
          code: 'asset.not_found',
          message: 'No assets found in GitHub release.',
        ),
      );
    }

    final pattern = apkPattern.trim().toLowerCase();

    for (final asset in release.assets) {
      final name = asset.name.toLowerCase();

      if (name.contains(pattern)) {
        return Success(asset);
      }
    }

    return Error(
      Failure(
        code: 'asset.not_found',
        message:
            'No asset matches pattern "$apkPattern".',
      ),
    );
  }
}