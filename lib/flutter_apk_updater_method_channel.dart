import 'package:flutter/services.dart';

import 'flutter_apk_updater_platform_interface.dart';
import 'src/models/failure.dart';
import 'src/models/result.dart';

class MethodChannelFlutterApkUpdater
    extends FlutterApkUpdaterPlatform {
  static const MethodChannel _channel = MethodChannel(
    'flutter_apk_updater',
  );

  MethodChannelFlutterApkUpdater() : super();

  @override
  Future<Result<void>> install({
    required String apkPath,
  }) async {
    try {
      await _channel.invokeMethod(
        'installApk',
        <String, dynamic>{
          'apkPath': apkPath,
        },
      );

      return const Success(null);
    } catch (exception, stackTrace) {
      return Error(
        Failure(
          code: 'platform.install_failed',
          message: 'Failed to invoke native installer.',
          exception: exception,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}