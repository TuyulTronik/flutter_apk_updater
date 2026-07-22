import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_apk_updater/flutter_apk_updater.dart';
import '../models/update_state.dart';
import '../widgets/update_info_card.dart';
import '../widgets/download_progress_widget.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  late ApkUpdater updater;
  UpdateState state = UpdateState.initial();
  UpdateInfo? currentUpdateInfo;
  DownloadInfo? currentDownloadInfo;

  @override
  void initState() {
    super.initState();
    _initializeUpdater();
  }

  void _initializeUpdater() {
    updater = ApkUpdater(
      config: const ApkUpdaterConfig(
        owner: 'TuyulTronik',
        repository: 'flutter_apk_updater',
        apkPattern: 'app-release',
      ),
      timeout: const Duration(seconds: 60),
    );
  }

  Future<void> _checkUpdate() async {
    if (!mounted) return;
    setState(() => state = state.loading());

    try {
      final result = await updater.check();

      if (!mounted) return;
      setState(() {
        if (result.isSuccess) {
          currentUpdateInfo = (result as Success<UpdateInfo>).data;
          state = state.success('Update check berhasil');
        } else {
          final failure = (result as Error<UpdateInfo>).failure;
          state = state.error('Gagal cek update: ${failure.message}');
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => state = state.error('Error: $e'));
    }
  }

  Future<void> _downloadAPK() async {
    if (currentUpdateInfo == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan cek update terlebih dahulu')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => state = state.loading());

    try {
      final result = await updater.download(
        updateInfo: currentUpdateInfo!,
        onProgress: (progress) {
          if (!mounted) return;
          setState(() {
            currentDownloadInfo = progress;
            state = UpdateState(
              status: UpdateStatus.downloading,
              message: 'Downloading: ${(progress.progress * 100).toStringAsFixed(1)}%',
              downloadProgress: progress,
            );
          });
        },
      );

      if (!mounted) return;
      setState(() {
        if (result.isSuccess) {
          currentDownloadInfo = (result as Success<DownloadInfo>).data;
          state = state.success('Download selesai');
        } else {
          final failure = (result as Error<DownloadInfo>).failure;
          state = state.error('Download gagal: ${failure.message}');
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => state = state.error('Error: $e'));
    }
  }

  Future<void> _installAPK() async {
    if (currentDownloadInfo == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan download APK terlebih dahulu')),
      );
      return;
    }

    final hasPermission = await updater.canRequestPackageInstalls();

    if (!hasPermission) {
      if (mounted) {
        _showPermissionDialog();
      }
      return;
    }

    if (!mounted) return;
    setState(() => state = state.loading());

    try {
      final result = await updater.install(
        apkPath: currentDownloadInfo!.localFilePath,
      );

      if (!mounted) return;
      setState(() {
        if (result.isSuccess) {
          state = state.success('Instalasi dimulai');
        } else {
          final failure = (result as Error<void>).failure;
          state = state.error('Install gagal: ${failure.message}');
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => state = state.error('Error: $e'));
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Izin Instalasi Diperlukan'),
        content: const Text(
          'Mohon izinkan instalasi dari sumber tidak dikenal '
          'untuk melanjutkan update aplikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // unawaited menandakan bahwa kita tidak perlu menunggu hasil
              unawaited(updater.openInstallSettings());
            },
            child: const Text('Buka Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Checker'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (state.message.isNotEmpty)
              Card(
                color: _getStatusColor(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _getStatusIcon(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            if (currentUpdateInfo != null)
              UpdateInfoCard(updateInfo: currentUpdateInfo!),
            const SizedBox(height: 24),
            if (state.status == UpdateStatus.downloading &&
                currentDownloadInfo != null)
              DownloadProgressWidget(downloadInfo: currentDownloadInfo!),
            const SizedBox(height: 24),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: state.isLoading ? null : _checkUpdate,
                    icon: const Icon(Icons.search),
                    label: const Text('Cek Update'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (state.isLoading || currentUpdateInfo == null)
                        ? null
                        : _downloadAPK,
                    icon: const Icon(Icons.download),
                    label: const Text('Download APK'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (state.isLoading || currentDownloadInfo == null)
                        ? null
                        : _installAPK,
                    icon: const Icon(Icons.install_mobile),
                    label: const Text('Install APK'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (state.status) {
      case UpdateStatus.success:
        return Colors.green;
      case UpdateStatus.error:
        return Colors.red;
      case UpdateStatus.loading:
      case UpdateStatus.downloading:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Widget _getStatusIcon() {
    switch (state.status) {
      case UpdateStatus.success:
        return const Icon(Icons.check_circle, color: Colors.white);
      case UpdateStatus.error:
        return const Icon(Icons.error, color: Colors.white);
      case UpdateStatus.loading:
      case UpdateStatus.downloading:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      default:
        return const Icon(Icons.info, color: Colors.white);
    }
  }
}