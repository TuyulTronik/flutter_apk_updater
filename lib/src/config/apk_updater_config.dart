class ApkUpdaterConfig {
  const ApkUpdaterConfig({
    required this.owner,
    required this.repository,
    required this.apkPattern,
    this.githubToken,
  });

  final String owner;

  final String repository;

  final String apkPattern;

  final String? githubToken;
}