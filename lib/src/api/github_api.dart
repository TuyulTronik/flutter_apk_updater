import 'package:dio/dio.dart';

import '../config/apk_updater_config.dart';
import '../models/failure.dart';
import '../models/github_release.dart';
import '../models/result.dart';

class GitHubApi {
  const GitHubApi({
    required this._dio,
  });

  static const String _acceptHeader = 'application/vnd.github+json';

  final Dio _dio;

  Future<Result<GitHubRelease>> getLatestRelease({
    required ApkUpdaterConfig config,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _buildUrl(config),
        options: _buildOptions(config),
      );

      final json = response.data;

      if (json == null) {
        return const Error(
          Failure(
            code: 'github.invalid_response',
            message: 'GitHub returned an empty response.',
          ),
        );
      }

      final release = GitHubRelease.fromJson(json);

      return Success(release);
    } on DioException catch (exception, stackTrace) {
      return Error(
        Failure(
          code: _mapDioErrorCode(exception),
          message: _mapDioErrorMessage(exception),
          exception: exception,
          stackTrace: stackTrace,
        ),
      );
    } catch (exception, stackTrace) {
      return Error(
        Failure(
          code: 'github.unknown',
          message: 'Unknown GitHub error.',
          exception: exception,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  String _buildUrl(ApkUpdaterConfig config) {
    return 'https://api.github.com/repos/'
        '${config.owner}/'
        '${config.repository}/'
        'releases/latest';
  }

  Options _buildOptions(ApkUpdaterConfig config) {
    final headers = <String, String>{
      'Accept': _acceptHeader,
    };

    final token = config.githubToken?.trim();

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return Options(headers: headers);
  }

  String _mapDioErrorCode(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'github.network';

      default:
        final statusCode = exception.response?.statusCode;

        switch (statusCode) {
          case 401:
            return 'github.unauthorized';

          case 404:
            return 'No GitHub Release found or repository does not exist.';

          default:
            return 'github.request_failed';
        }
    }
  }

  String _mapDioErrorMessage(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionError:
        return 'Failed to connect to GitHub.';

      case DioExceptionType.connectionTimeout:
        return 'Connection to GitHub timed out.';

      case DioExceptionType.receiveTimeout:
        return 'Receiving data from GitHub timed out.';

      case DioExceptionType.sendTimeout:
        return 'Sending request to GitHub timed out.';

      default:
        final statusCode = exception.response?.statusCode;

        switch (statusCode) {
          case 401:
            return 'GitHub authorization failed.';

          case 404:
            return 'GitHub repository or release not found.';

          default:
            return exception.message ?? 'GitHub request failed.';
        }
    }
  }
}