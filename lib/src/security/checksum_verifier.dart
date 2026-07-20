import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../models/failure.dart';
import '../models/result.dart';

/// Service untuk verifikasi checksum SHA256.
class ChecksumVerifier {
  ChecksumVerifier({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Verifikasi integritas APK dengan checksum SHA256.
  ///
  /// [apkPath] Path file APK yang sudah didownload.
  /// [checksumUrl] URL untuk download file .sha256.
  ///
  /// Returns:
  /// - `Success(true)` jika verifikasi berhasil
  /// - `Error(Failure)` jika verifikasi gagal
  Future<Result<bool>> verify({
    required String apkPath,
    required String checksumUrl,
  }) async {
    try {
      // 1. Download file checksum
      final checksumResponse = await _dio.get<String>(
        checksumUrl,
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (status) {
            return status != null && status >= 200 && status < 300;
          },
        ),
      );

      final checksumData = checksumResponse.data;

      if (checksumData == null || checksumData.isEmpty) {
        return Error(
          Failure(
            code: 'checksum.empty',
            message: 'File checksum kosong atau tidak ditemukan.',
          ),
        );
      }

      // 2. Parse checksum (ambil hash pertama yang ditemukan)
      final expectedChecksum = _parseChecksum(checksumData);

      if (expectedChecksum == null) {
        return Error(
          Failure(
            code: 'checksum.invalid_format',
            message:
                'Format checksum tidak valid. Harus berupa SHA256 hash (64 karakter hexadecimal).',
          ),
        );
      }

      // 3. Hitung checksum APK
      final apkFile = File(apkPath);

      if (!await apkFile.exists()) {
        return Error(
          Failure(
            code: 'checksum.file_not_found',
            message: 'File APK tidak ditemukan: $apkPath',
          ),
        );
      }

      final apkBytes = await apkFile.readAsBytes();
      final actualChecksum = sha256.convert(apkBytes).toString();

      // 4. Bandingkan
      if (actualChecksum != expectedChecksum) {
        return Error(
          Failure(
            code: 'checksum.mismatch',
            message:
                'Checksum tidak cocok.\n'
                'Expected: $expectedChecksum\n'
                'Actual: $actualChecksum',
          ),
        );
      }

      return const Success(true);
    } on DioException catch (exception, stackTrace) {
      return Error(
        Failure(
          code: 'checksum.download_failed',
          message: 'Gagal mendownload file checksum: ${exception.message}',
          exception: exception,
          stackTrace: stackTrace,
        ),
      );
    } catch (exception, stackTrace) {
      return Error(
        Failure(
          code: 'checksum.unknown',
          message: 'Error tidak dikenal saat verifikasi checksum: $exception',
          exception: exception,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Parse checksum dari berbagai format.
  ///
  /// Mendukung format:
  /// - `abc123...  filename.apk`
  /// - `abc123... *filename.apk`
  /// - `abc123...`
  String? _parseChecksum(String data) {
    // Ambil baris pertama
    final lines = data.split('\n');
    if (lines.isEmpty) return null;

    var line = lines[0].trim();

    // Regex untuk SHA256 hash (64 karakter hexadecimal)
    final hashRegex = RegExp(r'^[a-fA-F0-9]{64}');

    // Cari hash di awal string
    final match = hashRegex.firstMatch(line);
    if (match != null) {
      return match.group(0)?.toLowerCase();
    }

    // Coba split dengan spasi
    final parts = line.split(RegExp(r'\s+'));
    for (final part in parts) {
      if (hashRegex.hasMatch(part)) {
        return part.toLowerCase();
      }
    }

    return null;
  }

  /// Generate checksum untuk file (digunakan untuk testing).
  static Future<String> generateChecksum(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }
}
