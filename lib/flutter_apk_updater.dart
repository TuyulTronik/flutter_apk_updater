library;

// Core
export 'src/config/apk_updater_config.dart';
export 'src/updater/apk_updater.dart';

// Models
export 'src/models/download_info.dart';
export 'src/models/download_session.dart';
export 'src/models/failure.dart';
export 'src/models/github_asset.dart';
export 'src/models/github_release.dart';
export 'src/models/result.dart';
export 'src/models/update_info.dart';

// Security
export 'src/security/checksum_verifier.dart';

// Utils
export 'src/utils/storage_helper.dart';

// Platform Interface
export 'flutter_apk_updater_platform_interface.dart';
export 'flutter_apk_updater_method_channel.dart';

// Downloader
export 'src/downloader/apk_downloader.dart';

// Installer
export 'src/installer/update_installer.dart';

// Version
export 'src/version/version_comparator.dart';