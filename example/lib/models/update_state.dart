import 'package:flutter_apk_updater/flutter_apk_updater.dart';

enum UpdateStatus {
  initial,
  loading,
  success,
  error,
  downloading,
}

class UpdateState {
  final UpdateStatus status;
  final String message;
  final DownloadInfo? downloadProgress;

  UpdateState({
    required this.status,
    required this.message,
    this.downloadProgress,
  });

  factory UpdateState.initial() {
    return UpdateState(
      status: UpdateStatus.initial,
      message: '',
    );
  }

  bool get isLoading => status == UpdateStatus.loading || status == UpdateStatus.downloading;

  UpdateState loading() {
    return UpdateState(
      status: UpdateStatus.loading,
      message: 'Proses sedang berlangsung...',
    );
  }

  UpdateState success(String message) {
    return UpdateState(
      status: UpdateStatus.success,
      message: message,
    );
  }

  UpdateState error(String message) {
    return UpdateState(
      status: UpdateStatus.error,
      message: message,
    );
  }
}