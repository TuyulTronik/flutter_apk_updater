<!-- <p align="center">
  <img src="docs/images/banner.png" width="900">
</p> -->

<h1 align="center">
flutter_apk_updater
</h1>

<p align="center">
Lightweight Flutter package for checking, downloading, and installing Android APK updates directly from GitHub Releases.
</p>

<p align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Dart](https://img.shields.io/badge/Dart-3.x-blue)
![Android](https://img.shields.io/badge/Android-Only-green)
![GitHub Releases](https://img.shields.io/badge/GitHub-Releases-black)
![License](https://img.shields.io/badge/License-MIT-brightgreen)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
</p>

---

# Overview

`flutter_apk_updater` menyediakan solusi sederhana untuk melakukan pembaruan aplikasi Android tanpa bergantung pada Google Play Store.


Package ini memungkinkan aplikasi:

- memeriksa versi terbaru dari GitHub Releases,
- memilih APK yang sesuai,
- mengunduh APK,
- menampilkan progress download,
- menjalankan installer Android menggunakan `FileProvider`.

Seluruh proses dibangun menggunakan Flutter dan native Android (Kotlin) melalui `MethodChannel`.
> **Catatan**: Package ini dikembangkan khusus untuk **Android** dan tidak mendukung iOS, Web, atau platform lainnya.
---

# Features
## ✨ Fitur

- ✅ **Cek Update Otomatis** dari GitHub Releases
- ✅ **Download APK** dengan progress tracking
- ✅ **Install APK** secara otomatis
- ✅ **Dukungan Private Repository** (dengan GitHub Token)
- ✅ **Session Download** (resume download jika terputus)
- ✅ **Version Comparison** (SemVer)
- ✅ **Asset Filtering** berdasarkan pattern
- ✅ **Error Handling** yang komprehensif

---

# Installation
## Public
```yaml
dependencies:
  flutter_apk_updater:
    git:
      url: https://github.com/TuyulTronik/flutter_apk_updater.git
      ref: main
```
## Private (SSH)
```yaml
dependencies:
  flutter_apk_updater:
    git:
      url: git@github.com:TuyulTronik/flutter_apk_updater.git
      ref: main
```
---
# ⚙️ Konfigurasi
---
1. Android Manifest
Tambahkan permission berikut ke android/app/src/main/AndroidManifest.xml:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```
2. FileProvider
Tambahkan provider ke AndroidManifest.xml:
```xml
<application>
    <provider
        android:name="androidx.core.content.FileProvider"
        android:authorities="${applicationId}.flutter_apk_updater.fileprovider"
        android:exported="false"
        android:grantUriPermissions="true">
        <meta-data
            android:name="android.support.FILE_PROVIDER_PATHS"
            android:resource="@xml/flutter_apk_updater_paths" />
    </provider>
</application>
```
3. Persiapkan GitHub Release
```
1. Buat Release di repository GitHub Anda
2. Upload file APK sebagai asset
3. Pastikan tag version mengikuti format SemVer (contoh: 1.0.0, v2.1.3)
```
---
# 🚀 Penggunaan Dasar
---
## Inisialisasi
```dart
import 'package:flutter_apk_updater/flutter_apk_updater.dart';

final updater = ApkUpdater(
  config: ApkUpdaterConfig(
    owner: 'TuyulTronik',           // Owner GitHub
    repository: 'my_app',           // Nama repository
    apkPattern: 'app-release',      // Pattern untuk filter APK
    githubToken: 'your_token_here', // Opsional, untuk private repo
  ),
);
```
## Cek Update
```dart
final checkResult = await updater.check();

if (checkResult.isSuccess) {
  final updateInfo = (checkResult as Success<UpdateInfo>).data;
  
  if (updateInfo.hasUpdate) {
    print('Update tersedia: ${updateInfo.latestVersion}');
    print('Versi saat ini: ${updateInfo.currentVersion}');
    print('Release notes: ${updateInfo.release.releaseNotes}');
    
    // Lanjutkan ke download
  } else {
    print('Aplikasi sudah terbaru');
  }
} else {
  final failure = (checkResult as Error<UpdateInfo>).failure;
  print('Gagal cek update: ${failure.message}');
}
```
## Download APK
```dart
final downloadResult = await updater.download(
  updateInfo: updateInfo,
  onProgress: (progress) {
    print('Download: ${(progress.progress * 100).toStringAsFixed(1)}%');
    print('Bytes: ${progress.receivedBytes}/${progress.totalBytes}');
  },
);

if (downloadResult.isSuccess) {
  final downloadInfo = (downloadResult as Success<DownloadInfo>).data;
  print('APK berhasil didownload: ${downloadInfo.localFilePath}');
  
  // Lanjutkan ke install
} else {
  final failure = (downloadResult as Error<DownloadInfo>).failure;
  print('Gagal download: ${failure.message}');
}
```
## Install APK
```dart
final installResult = await updater.install(
  apkPath: downloadInfo.localFilePath,
);

if (installResult.isSuccess) {
  print('Installasi dimulai');
} else {
  final failure = (installResult as Error<void>).failure;
  print('Gagal install: ${failure.message}');
}
```
---
# 📖 API Reference
## ApkUpdater
Kelas utama untuk melakukan update APK.
### Konstruktor
```dart
ApkUpdater({
  required ApkUpdaterConfig config,
})
```
### Metode
| Metode | Return | Deskripsi |
|---------|--------|----------|
| check |	Future<Result<UpdateInfo>> |	Cek apakah ada update baru |
| download |	Future<Result<DownloadInfo>> |	Download APK dari GitHub Release |
| install |	Future<Result<void>> |	Install APK yang sudah didownload |

### ApkUpdaterConfig
Konfigurasi untuk updater.
```dart
class ApkUpdaterConfig {
  const ApkUpdaterConfig({
    required this.owner,          // GitHub owner (username/organisasi)
    required this.repository,     // Nama repository
    required this.apkPattern,     // Pattern untuk filter asset APK
    this.githubToken,             // Token untuk private repository
  });
}
```
| Parameter | Type | Deskripsi |
|---------|--------|----------|
| owner | String| Username atau organisasi GitHub |
| repository | String| Nama repository GitHub |
| apkPattern | String| Pattern untuk memilih asset APK (contoh: 'app-release') |
| githubToken | String?| Token GitHub untuk akses private repository |

### UpdateInfo
Informasi hasil pengecekan update.
```dart
class UpdateInfo {
  final String currentVersion;     // Versi aplikasi saat ini
  final String latestVersion;      // Versi terbaru di GitHub
  final bool hasUpdate;            // Apakah ada update?
  final GitHubRelease release;     // Data release dari GitHub
  final GitHubAsset asset;         // Asset APK yang dipilih
}
```
### DownloadInfo
```dart
class DownloadInfo {
  final int receivedBytes;         // Bytes yang sudah didownload
  final int totalBytes;            // Total bytes file
  final String localFilePath;      // Lokasi file APK di device
  
  double get progress;             // Progress 0.0 - 1.0
  bool get isCompleted;            // Apakah download selesai?
}
```
### Result<T>
Pattern untuk handling hasil operasi.
```dart
sealed class Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;
}

// Success
final success = Success(data);

// Error
final error = Error(failure);
```
### Error Codes
| Code | Deskripsi |
|------|-----------|
| github.network | Gagal terhubung ke GitHub |
| github.unauthorized | Token GitHub tidak valid |
| github.not_found | Repository atau release tidak ditemukan |
| github.request_failed | Request ke GitHub gagal |
| asset.not_found	Asset | APK tidak ditemukan di release |
| version.invalid |	Format versi tidak valid (bukan SemVer) |
| download.failed |	Download gagal |
| download.invalid_response |	Response dari server tidak valid |
| download.unknown |	Error unknown saat download |
| install_failed | Gagal install APK |
| permission_denied |	Permission install tidak diberikan |
---
# 💡 Contoh Lengkap
Contoh UI Update Checker

---
```dart
import 'package:flutter/material.dart';
import 'package:flutter_apk_updater/flutter_apk_updater.dart';

class UpdateChecker extends StatefulWidget {
  @override
  _UpdateCheckerState createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends State<UpdateChecker> {
  final updater = ApkUpdater(
    config: ApkUpdaterConfig(
      owner: 'TuyulTronik',
      repository: 'my_app',
      apkPattern: 'app-release',
    ),
  );

  bool _isLoading = false;
  String _status = '';

  Future<void> _checkUpdate() async {
    setState(() {
      _isLoading = true;
      _status = 'Mengecek update...';
    });

    try {
      final result = await updater.check();

      if (result.isSuccess) {
        final info = (result as Success<UpdateInfo>).data;

        if (info.hasUpdate) {
          setState(() {
            _status = 'Update tersedia: ${info.latestVersion}';
          });
          _showUpdateDialog(info);
        } else {
          setState(() {
            _status = 'Aplikasi sudah terbaru (${info.currentVersion})';
          });
        }
      } else {
        final failure = (result as Error<UpdateInfo>).failure;
        setState(() {
          _status = 'Error: ${failure.message}';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showUpdateDialog(UpdateInfo info) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Tersedia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versi baru: ${info.latestVersion}'),
            SizedBox(height: 8),
            Text('Versi saat ini: ${info.currentVersion}'),
            if (info.release.releaseNotes.isNotEmpty) ...[
              SizedBox(height: 8),
              Text('Release Notes:'),
              Text(
                info.release.releaseNotes,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Nanti'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _downloadAndInstall(info);
            },
            child: Text('Update Sekarang'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAndInstall(UpdateInfo info) async {
    // Implementasi download & install
    // ...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Checker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkUpdate,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Cek Update'),
            ),
          ],
        ),
      ),
    );
  }
}
```
---
# 🔧 Troubleshooting
## Permission Denied
Masalah: Installasi gagal dengan error "permission_denied"

Solusi:

1. Pastikan permission REQUEST_INSTALL_PACKAGES sudah diberikan
2. Pada Android 8+, pengguna harus mengizinkan "Install unknown apps" untuk aplikasi Anda
3. Arahkan pengguna ke settings:
```dart
if (await canRequestPackageInstalls()) {
  // Install
} else {
  // Arahkan ke settings
  await openAppSettings();
}
```
## Asset Tidak Ditemukan
Masalah: Error "No asset matches pattern"
Solusi:
1. Pastikan pattern apkPattern sesuai dengan nama file APK di GitHub Release
2. Pattern bersifat case-insensitive (menggunakan contains)
3. Contoh: jika file bernama app-release-1.0.0.apk, pattern yang tepat adalah app-release

## Version Parsing Error
Masalah: Error "Invalid semantic version"
Solusi:
1. Pastikan tag version di GitHub mengikuti format SemVer
2. Format yang didukung: 1.0.0, 2.1.3-beta, v1.2.3
3. Format yang TIDAK didukung: 1.0, 2.1, release-1.0

## Download Gagal di Tengah Jalan
Masalah: Download terputus karena network error
Solusi:
1. Package sudah mendukung session storage
2. Download akan tetap tersimpan di getApplicationSupportDirectory()
3. Saat mencoba download ulang, seharusnya resume dari session yang tersimpan
4. Jika tidak resume, hapus session: await DownloadSessionStorage().clear()

---
# 📄 Lisensi
---
Copyright © 2024 TuyulTronik

Dilisensikan di bawah MIT License.
---
# Additional information
- **Repository : [https://github.com/TuyulTronik/flutter_apk_updater](https://github.com/TuyulTronik/flutter_apk_updater) 
- **Inspired By : [github_release_apk_updater](https://github.com/TuyulTronik/flutter_apk_updater) 