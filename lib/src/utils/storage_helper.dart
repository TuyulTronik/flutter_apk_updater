import 'dart:io';

import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';

/// Helper untuk operasi storage.
class StorageHelper {
  const StorageHelper();

  /// Mendapatkan free space dalam bytes.
  ///// 1. Definisikan MethodChannel dengan nama yang unik
  static const MethodChannel _channel = MethodChannel('flutter_apk_updater/storage');

  /// Mendapatkan free space internal dalam bytes.
  ///
  /// Returns:
  /// - `int` jumlah free space dalam bytes
  /// - `null` jika tidak bisa mendapatkan informasi
  Future<int?> getFreeSpace() async {
    try {
      // 2. Panggil method 'getFreeSpace' di sisi native
      final freeSpace = await _channel.invokeMethod<int>('getFreeSpace');
      return freeSpace;
    } catch (e) {
      // 3. Jika gagal, return null sebagai fallback
      return null;
    }
  }

  /// Cek apakah storage mencukupi.
  ///
  /// [requiredBytes] Bytes yang dibutuhkan.
  /// [buffer] Buffer tambahan (default 10%).
  ///
  /// Returns:
  /// - `true` jika cukup
  /// - `false` jika tidak cukup atau tidak bisa cek
  Future<bool> hasEnoughSpace({
    required int requiredBytes,
    double buffer = 0.1,
  }) async {
    final freeSpace = await getFreeSpace();

    if (freeSpace == null) {
      // Jika tidak bisa cek, asumsikan cukup
      return true;
    }

    final requiredWithBuffer = (requiredBytes * (1 + buffer)).ceil();
    return freeSpace >= requiredWithBuffer;
  }

  /// Format bytes ke string yang mudah dibaca.
  static String formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }

    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Mendapatkan ukuran file.
  static Future<int> getFileSize(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return 0;
    }
    final stat = await file.stat();
    return stat.size;
  }

  /// Menghapus file jika ada.
  static Future<bool> deleteFileIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      return true;
    }
    return false;
  }
}