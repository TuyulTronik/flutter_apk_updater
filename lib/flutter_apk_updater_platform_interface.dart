import 'dart:async';
import 'package:flutter/foundation.dart';
import 'flutter_apk_updater.dart';

/// Interface untuk platform-specific implementations.
abstract class FlutterApkUpdaterPlatform {
  /// Instance singleton dari platform interface.
  static FlutterApkUpdaterPlatform _instance = MethodChannelFlutterApkUpdater();

  /// Mendapatkan instance platform interface.
  static FlutterApkUpdaterPlatform get instance => _instance;

  /// Set instance platform interface (untuk testing).
  @visibleForTesting
  static set instance(FlutterApkUpdaterPlatform instance) {
    _instance = instance;
  }

  /// Install APK dari path yang diberikan.
  ///
  /// [apkPath] Path absolut ke file APK di device.
  ///
  /// Returns:
  /// - `Success<void>` jika installasi berhasil dimulai
  /// - `Error<Failure>` jika terjadi error
  Future<Result<void>> install({required String apkPath});

  /// Cek apakah aplikasi memiliki izin untuk install APK.
  ///
  /// Returns:
  /// - `true` jika memiliki izin
  /// - `false` jika tidak memiliki izin
  Future<bool> canRequestPackageInstalls();

  /// Buka halaman settings untuk mengizinkan install dari sumber tidak dikenal.
  ///
  /// Returns:
  /// - `true` jika berhasil membuka settings
  /// - `false` jika gagal
  Future<bool> openInstallSettings();

  /// BARU: Close app
  Future<void> closeApp();
}
