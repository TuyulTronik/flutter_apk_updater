import 'github_asset.dart';

class GitHubRelease {
  const GitHubRelease({
    required this.version,
    required this.releaseNotes,
    required this.publishedAt,
    required this.assets,
  });

  factory GitHubRelease.fromJson(Map<String, dynamic> json) {
    final assets = (json['assets'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(GitHubAsset.fromJson)
        .toList();

    return GitHubRelease(
      version: (json['tag_name'] as String).trim(),
      releaseNotes: (json['body'] as String?) ?? '',
      publishedAt: DateTime.parse(json['published_at'] as String),
      assets: assets,
    );
  }

  final String version;

  final String releaseNotes;

  final DateTime publishedAt;

  final List<GitHubAsset> assets;
}
