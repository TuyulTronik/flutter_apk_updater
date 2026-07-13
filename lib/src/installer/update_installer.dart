import '../../flutter_apk_updater_platform_interface.dart';
import '../models/result.dart';

class UpdateInstaller {
  const UpdateInstaller();

  Future<Result<void>> install({
    required String apkPath,
  }) {
    return FlutterApkUpdaterPlatform.instance.install(
      apkPath: apkPath,
    );
  }
}