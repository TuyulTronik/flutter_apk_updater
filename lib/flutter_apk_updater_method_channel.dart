import 'package:flutter/services.dart';
import 'package:flutter_apk_updater/flutter_apk_updater.dart';



/// Platform implementation menggunakan MethodChannel.
class MethodChannelFlutterApkUpdater extends FlutterApkUpdaterPlatform {
  MethodChannelFlutterApkUpdater() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static const MethodChannel _channel = MethodChannel('flutter_apk_updater');

  /// Handler untuk method call dari native.
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      // Handle callback dari native jika diperlukan
      default:
        throw PlatformException(
          code: 'unimplemented',
          message: 'Method ${call.method} not implemented',
        );
    }
  }

  @override
  Future<Result<void>> install({required String apkPath}) async {
    try {
      await _channel.invokeMethod('installApk', {'apkPath': apkPath});
      return const Success(null);
    } on PlatformException catch (e) {
      return Error(
        Failure(
          code: e.code,
          message: e.message ?? 'Installation failed.',
          exception: e,
        ),
      );
    } catch (e, stackTrace) {
      return Error(
        Failure(
          code: 'install.unknown',
          message: 'Unexpected error during installation.',
          exception: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<bool> canRequestPackageInstalls() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'canRequestPackageInstalls',
      );
      return result ?? false;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> openInstallSettings() async {
    try {
      final result = await _channel.invokeMethod<bool>('openInstallSettings');
      return result ?? false;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
