import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../config/apk_updater_config.dart';
import '../models/download_info.dart';
import '../models/download_session.dart';
import '../models/failure.dart';
import '../models/github_asset.dart';
import '../models/github_release.dart';
import '../models/result.dart';
import '../security/checksum_verifier.dart';
import '../session/download_session_storage.dart';
import '../utils/storage_helper.dart';

typedef DownloadProgressCallback = void Function(DownloadInfo progress);

class ApkDownloadService {
  ApkDownloadService({
    Dio? dio,
    DownloadSessionStorage? sessionStorage,
    ChecksumVerifier? checksumVerifier,
    StorageHelper? storageHelper,
  }) : _dio = dio ?? Dio(),
       _sessionStorage = sessionStorage ?? const DownloadSessionStorage(),
       _checksumVerifier = checksumVerifier ?? ChecksumVerifier(),
       _storageHelper = storageHelper ?? const StorageHelper();

  static const int _sessionSaveThreshold = 1024 * 1024; // 1MB
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  final Dio _dio;
  final DownloadSessionStorage _sessionStorage;
  final ChecksumVerifier _checksumVerifier;
  final StorageHelper _storageHelper;

  CancelToken? _cancelToken;

  /// Download APK dengan retry mechanism, storage check, dan checksum verification.
  Future<Result<DownloadInfo>> download({
    required GitHubRelease release,
    required GitHubAsset asset,
    required ApkUpdaterConfig config,
    DownloadProgressCallback? onProgress,
  }) async {
    int retryCount = 0;

    while (retryCount < _maxRetries) {
      final result = await _attemptDownload(
        release: release,
        asset: asset,
        config: config,
        onProgress: onProgress,
      );

      if (result.isSuccess) {
        return result;
      }

      final failure = (result as Error<DownloadInfo>).failure;

      // Cek apakah error recoverable (network error)
      if (_isRecoverableError(failure.code) && retryCount < _maxRetries - 1) {
        retryCount++;
        await Future.delayed(_retryDelay * (retryCount)); // Linear backoff
        continue;
      }

      return result;
    }

    return Error(
      Failure(
        code: 'download.max_retries',
        message: 'Gagal download setelah $_maxRetries kali percobaan.',
      ),
    );
  }

  /// Internal method untuk satu kali percobaan download.
  Future<Result<DownloadInfo>> _attemptDownload({
    required GitHubRelease release,
    required GitHubAsset asset,
    required ApkUpdaterConfig config,
    DownloadProgressCallback? onProgress,
  }) async {
    RandomAccessFile? randomAccessFile;
    File? downloadFile;
    DownloadSession? session;

    try {
      // 1. Cek storage space
      final hasSpace = await _storageHelper.hasEnoughSpace(
        requiredBytes: asset.size,
      );

      if (!hasSpace) {
        final freeSpace = await _storageHelper.getFreeSpace();
        return Error(
          Failure(
            code: 'storage.insufficient',
            message:
                'Storage tidak mencukupi.\n'
                'Membutuhkan: ${StorageHelper.formatSize(asset.size)}\n'
                'Tersedia: ${freeSpace != null ? StorageHelper.formatSize(freeSpace) : 'tidak diketahui'}',
          ),
        );
      }

      // 2. Persiapkan direktori
      final directory = await getApplicationSupportDirectory();

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // 3. Overwrite: hapus file lama jika ada
      final downloadPath = '${directory.path}/${asset.name}';
      downloadFile = File(downloadPath);

      if (await downloadFile.exists()) {
        await downloadFile.delete();
      }

      await downloadFile.create(recursive: true);

      randomAccessFile = await downloadFile.open(
        mode: FileMode.writeOnlyAppend,
      );

      _cancelToken = CancelToken();

      // 4. Download
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

      // 5. Buat session
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

      // 6. Stream download dengan progress
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

      // 7. Verifikasi checksum (jika diaktifkan)
      if (config.verifyChecksum) {
        final checksumAsset = release.findChecksumAsset(asset.name);

        if (checksumAsset == null) {
          await _deleteFile(downloadFile);
          return Error(
            Failure(
              code: 'checksum.file_not_found',
              message:
                  'File checksum tidak ditemukan di GitHub Release.\n'
                  'Buat file ${asset.name}.sha256 dan upload ke release.',
            ),
          );
        }

        final verifyResult = await _checksumVerifier.verify(
          apkPath: downloadFile.path,
          checksumUrl: checksumAsset.downloadUrl,
        );

        if (verifyResult.isError) {
          final failure = (verifyResult as Error<bool>).failure;
          await _deleteFile(downloadFile);
          return Error(failure);
        }
      }

      return Success(
        DownloadInfo(
          receivedBytes: receivedBytes,
          totalBytes: totalBytes,
          localFilePath: downloadFile.path,
        ),
      );
    } on DioException catch (exception, stackTrace) {
      // Simpan session untuk recoverable errors
      if (_isRecoverableDioError(exception) && session != null) {
        await _deleteFile(downloadFile);
        session = session.copyWith(updatedAt: DateTime.now());
        await _sessionStorage.save(session);
      } else {
        await _deleteFile(downloadFile);
        await _sessionStorage.clear();
      }

      return Error(
        Failure(
          code: _mapDioErrorCode(exception),
          message: _mapDioErrorMessage(exception),
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
          message: 'Unexpected download error: $exception',
          exception: exception,
          stackTrace: stackTrace,
        ),
      );
    } finally {
      _cancelToken = null;
      await randomAccessFile?.close();
    }
  }

  /// Batalkan download yang sedang berjalan.
  void cancel() {
    _cancelToken?.cancel('Download cancelled by user.');
  }

  /// Cek apakah error recoverable (dapat dicoba ulang).
  bool _isRecoverableError(String errorCode) {
    return errorCode.startsWith('github.network') ||
        errorCode.startsWith('download.network') ||
        errorCode == 'download.timeout' ||
        errorCode == 'download.failed';
  }

  /// Cek apakah DioException recoverable.
  bool _isRecoverableDioError(DioException exception) {
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

  /// Map DioException ke error code.
  String _mapDioErrorCode(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'download.network';

      default:
        final statusCode = exception.response?.statusCode;
        if (statusCode == 404) {
          return 'download.file_not_found';
        }
        return 'download.failed';
    }
  }

  /// Map DioException ke error message.
  String _mapDioErrorMessage(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server.';
      case DioExceptionType.connectionTimeout:
        return 'Koneksi ke server timeout.';
      case DioExceptionType.receiveTimeout:
        return 'Menerima data timeout.';
      case DioExceptionType.sendTimeout:
        return 'Mengirim data timeout.';
      default:
        final statusCode = exception.response?.statusCode;
        if (statusCode == 404) {
          return 'File tidak ditemukan di server.';
        }
        return exception.message ?? 'Download gagal.';
    }
  }

  /// Hapus file jika ada.
  Future<void> _deleteFile(File? file) async {
    if (file == null) return;
    if (!await file.exists()) return;
    await file.delete();
  }
}