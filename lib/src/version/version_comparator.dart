import 'package:pub_semver/pub_semver.dart';

import '../models/failure.dart';
import '../models/result.dart';

enum VersionComparison {
  older,
  equal,
  newer,
}

class VersionComparator {
  const VersionComparator();

  Result<VersionComparison> compare({
    required String currentVersion,
    required String latestVersion,
  }) {
    try {
      final current = Version.parse(_normalize(currentVersion));
      final latest = Version.parse(_normalize(latestVersion));

      if (current < latest) {
        return const Success(VersionComparison.older);
      }

      if (current > latest) {
        return const Success(VersionComparison.newer);
      }

      return const Success(VersionComparison.equal);
    } on FormatException catch (exception, stackTrace) {
      return Error(
        Failure(
          code: 'version.invalid',
          message: 'Invalid semantic version.',
          exception: exception,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Result<bool> hasUpdate({
    required String currentVersion,
    required String latestVersion,
  }) {
    final comparison = compare(
      currentVersion: currentVersion,
      latestVersion: latestVersion,
    );

    if (comparison is Error<VersionComparison>) {
      return Error(comparison.failure);
    }

    final result = comparison as Success<VersionComparison>;

    return Success(result.data == VersionComparison.older);
  }

  String _normalize(String version) {
    final normalized = version.trim();

    if (normalized.startsWith('v') || normalized.startsWith('V')) {
      return normalized.substring(1);
    }

    return normalized;
  }
}