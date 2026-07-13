import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../models/download_info.dart';
import '../models/download_session.dart';
import '../models/failure.dart';
import '../models/github_asset.dart';
import '../models/github_release.dart';
import '../models/result.dart';
import '../session/download_session_storage.dart';

typedef DownloadProgressCallback = void Function(DownloadInfo progress);

class ApkDownloadService {
  ApkDownloadService({Dio? dio, DownloadSessionStorage? sessionStorage})
    : _dio = dio ?? Dio(),
      _sessionStorage = sessionStorage ?? const DownloadSessionStorage();

  static const int _sessionSaveThreshold = 1024 * 1024;

  final Dio _dio;

  final DownloadSessionStorage _sessionStorage;

  CancelToken? _cancelToken;

  Future<Result<DownloadInfo>> download({
    required GitHubRelease release,
    required GitHubAsset asset,
    DownloadProgressCallback? onProgress,
  }) async {
    RandomAccessFile? randomAccessFile;
    File? downloadFile;
    DownloadSession? session;

    try {
      final directory = await getApplicationSupportDirectory();

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      downloadFile = File('${directory.path}/${asset.name}');

      if (await downloadFile.exists()) {
        await downloadFile.delete();
      }

      await downloadFile.create(recursive: true);

      randomAccessFile = await downloadFile.open(
        mode: FileMode.writeOnlyAppend,
      );

      _cancelToken = CancelToken();

      final response = await _dio.get<ResponseBody>(
        asset.downloadUrl,
        options: Options(
          responseType: ResponseType.stream,
          validateStatus: (status) {
            return status != null && status >= 200 && status < 300;
          },
        ),
        cancelToken: _cancelToken,
      );

      final responseBody = response.data;

      if (responseBody == null) {
        throw const HttpException('Empty response body.');
      }

      final totalBytes = responseBody.contentLength;

      final now = DateTime.now();

      session = DownloadSession(
        version: release.version,
        downloadUrl: asset.downloadUrl,
        filePath: downloadFile.path,
        totalBytes: totalBytes,
        downloadedBytes: 0,
        createdAt: now,
        updatedAt: now,
      );

      await _sessionStorage.save(session);

      var receivedBytes = 0;
      var lastSavedBytes = 0;

      await for (final chunk in responseBody.stream) {
        await randomAccessFile.writeFrom(chunk);

        receivedBytes += chunk.length;

        session = session!.copyWith(
          downloadedBytes: receivedBytes,
          updatedAt: DateTime.now(),
        );

        if (receivedBytes - lastSavedBytes >= _sessionSaveThreshold) {
          await _sessionStorage.save(session);

          lastSavedBytes = receivedBytes;
        }

        onProgress?.call(
          DownloadInfo(
            receivedBytes: receivedBytes,
            totalBytes: totalBytes,
            localFilePath: downloadFile.path,
          ),
        );
      }

      await randomAccessFile.flush();

      await _sessionStorage.clear();

      return Success(
        DownloadInfo(
          receivedBytes: receivedBytes,
          totalBytes: totalBytes,
          localFilePath: downloadFile.path,
        ),
      );
    } on DioException catch (exception, stackTrace) {
      if (_isRecoverable(exception) && session != null) {
        await _deleteFile(downloadFile);

        session = session.copyWith(updatedAt: DateTime.now());

        await _sessionStorage.save(session);
      } else {
        await _deleteFile(downloadFile);
        await _sessionStorage.clear();
      }

      return Error(
        Failure(
          code: 'download.failed',
          message: exception.message ?? 'Download failed.',
          exception: exception,
          stackTrace: stackTrace,
        ),
      );
    } on HttpException catch (exception, stackTrace) {
      await _deleteFile(downloadFile);
      await _sessionStorage.clear();

      return Error(
        Failure(
          code: 'download.invalid_response',
          message: exception.message,
          exception: exception,
          stackTrace: stackTrace,
        ),
      );
    } catch (exception, stackTrace) {
      await _deleteFile(downloadFile);
      await _sessionStorage.clear();

      return Error(
        Failure(
          code: 'download.unknown',
          message: 'Unexpected download error.',
          exception: exception,
          stackTrace: stackTrace,
        ),
      );
    } finally {
      _cancelToken = null;

      await randomAccessFile?.close();
    }
  }

  void cancel() {
    _cancelToken?.cancel('Download cancelled.');
  }

  bool _isRecoverable(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;

      default:
        return false;
    }
  }

  Future<void> _deleteFile(File? file) async {
    if (file == null) {
      return;
    }

    if (!await file.exists()) {
      return;
    }

    await file.delete();
  }
}
