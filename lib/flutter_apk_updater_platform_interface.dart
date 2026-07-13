import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_apk_updater_method_channel.dart';

import 'src/models/result.dart';

abstract class FlutterApkUpdaterPlatform extends PlatformInterface {
  FlutterApkUpdaterPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterApkUpdaterPlatform _instance = MethodChannelFlutterApkUpdater();
  static FlutterApkUpdaterPlatform get instance => _instance;

  static set instance(FlutterApkUpdaterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);

    _instance = instance;
  }

  Future<Result<void>> install({required String apkPath});
}
