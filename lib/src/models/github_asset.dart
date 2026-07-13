class GitHubAsset {
  const GitHubAsset({
    required this.name,
    required this.downloadUrl,
    required this.size,
  });

  factory GitHubAsset.fromJson(Map<String, dynamic> json) {
    return GitHubAsset(
      name: json['name'] as String,
      downloadUrl: json['browser_download_url'] as String,
      size: (json['size'] as num).toInt(),
    );
  }

  final String name;

  final String downloadUrl;

  final int size;
}