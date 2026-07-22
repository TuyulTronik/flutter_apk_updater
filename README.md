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
![GitHub Releases](https://img.shields.io/badge/GitHub-Releases-brightgreen)
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
- ✅ **APK Integrity** (opsional, verifikasi SHA256) 🔒
- ✅ **Retry Mechanism** (3x untuk network errors) 🔄
- ✅ **Storage Check** sebelum download 💾
- ✅ **Permission Handling** runtime untuk Android 8+ 📱
- ✅ **Auto Delete** configurable (default: false) 🗑️

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
<!-- READ_EXTERNAL_STORAGE: biasanya tidak diperlukan karena file disimpan di direktori aplikasi (getApplicationSupportDirectory()).
     Hanya aktifkan jika Anda menyimpan APK di storage eksternal dan menarget API yang memerlukan izin ini. -->
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
4. Hanya support awalan 'v' atau 'V'
```
### Advanced Configuration

```dart
final updater = ApkUpdater(
  config: ApkUpdaterConfig(
    owner: 'TuyulTronik',
    repository: 'my_app',
    apkPattern: 'app-release',
    
    // Optional: Untuk private repository
    githubToken: 'your_token_here',
    // Atau lebih aman dengan tokenProvider
    tokenProvider: () async {
      // Ambil token dari secure storage
      return await secureStorage.read(key: 'github_token');
    },
    
    // Optional: Verifikasi checksum (SHA256)
    verifyChecksum: true,
    
    // Optional: Auto delete setelah install
    autoDeleteAfterInstall: false,
  ),
  
  // Optional: Timeout untuk network requests
  timeout: Duration(seconds: 60),
);
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
---
```dart
import 'package:flutter/material.dart';
import 'package:flutter_apk_updater/flutter_apk_updater.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APK Updater Simple',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const SimpleUpdatePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SimpleUpdatePage extends StatefulWidget {
  const SimpleUpdatePage({Key? key}) : super(key: key);

  @override
  State<SimpleUpdatePage> createState() => _SimpleUpdatePageState();
}

class _SimpleUpdatePageState extends State<SimpleUpdatePage> {
  late ApkUpdater updater;
  String status = 'Tekan tombol untuk mulai';
  UpdateInfo? updateInfo;
  double downloadProgress = 0;

  @override
  void initState() {
    super.initState();
    updater = ApkUpdater(
      config: const ApkUpdaterConfig(
        owner: 'TuyulTronik',
        repository: 'flutter_apk_updater',
        apkPattern: 'app-release',
      ),
    );
  }

  Future<void> checkAndUpdate() async {
    try {
      setState(() => status = 'Checking updates...');

      final checkResult = await updater.check();

      if (checkResult.isSuccess) {
        final info = (checkResult as Success<UpdateInfo>).data;
        setState(() {
          updateInfo = info;
          status = info.hasUpdate
              ? 'Update available: ${info.latestVersion}'
              : 'Already up to date';
        });

        if (info.hasUpdate) {
          await downloadAndInstall(info);
        }
      } else {
        final error = (checkResult as Error<UpdateInfo>).failure;
        setState(() => status = 'Error: ${error.message}');
      }
    } catch (e) {
      setState(() => status = 'Exception: $e');
    }
  }

  Future<void> downloadAndInstall(UpdateInfo info) async {
    try {
      setState(() => status = 'Downloading...');

      final downloadResult = await updater.download(
        updateInfo: info,
        onProgress: (progress) {
          setState(() {
            downloadProgress = progress.progress;
            status =
                'Downloading: ${(progress.progress * 100).toStringAsFixed(1)}%';
          });
        },
      );

      if (downloadResult.isSuccess) {
        final downloadInfo = (downloadResult as Success<DownloadInfo>).data;

        setState(() => status = 'Checking permissions...');

        final hasPermission = await updater.canRequestPackageInstalls();

        if (!hasPermission) {
          setState(() => status = 'Permission required. Opening settings...');
          await updater.openInstallSettings();
          return;
        }

        setState(() => status = 'Installing...');

        final installResult =
            await updater.install(apkPath: downloadInfo.localFilePath);

        if (installResult.isSuccess) {
          setState(() => status = 'Installation started!');
        } else {
          final error = (installResult as Error<void>).failure;
          setState(() => status = 'Install failed: ${error.message}');
        }
      } else {
        final error = (downloadResult as Error<DownloadInfo>).failure;
        setState(() => status = 'Download failed: ${error.message}');
      }
    } catch (e) {
      setState(() => status = 'Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple APK Updater')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.system_update, size: 64, color: Colors.blue),
              const SizedBox(height: 32),
              Text(
                status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              if (downloadProgress > 0 && downloadProgress < 1)
                Column(
                  children: [
                    LinearProgressIndicator(value: downloadProgress),
                    const SizedBox(height: 16),
                  ],
                ),
              ElevatedButton.icon(
                onPressed: checkAndUpdate,
                icon: const Icon(Icons.update),
                label: const Text('Check & Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```
## Menangani Permission Denied
```dart
final installResult = await updater.install(apkPath: path);

if (installResult.isError) {
  final failure = (installResult as Error<void>).failure;
  if (failure.code == 'permission_denied') {
    // Tampilkan dialog dan arahkan ke settings
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Izin Instalasi Diperlukan'),
        content: Text(
          'Mohon izinkan instalasi dari sumber tidak dikenal '
          'untuk melanjutkan update aplikasi.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Gunakan method dari updater untuk membuka settings install apps
              await updater.openInstallSettings();
              Navigator.pop(context);
            },
            child: Text('Buka Settings'),
          ),
        ],
      ),
    );
  }
}
```
## Note :
> **Catatan**: Untuk contoh implementasi yang lebih lengkap bisa cek **example** dalam repository.
---

# 🔧 Troubleshooting
## Permission Denied
Masalah: Installasi gagal dengan error "permission_denied"

Solusi:

1. Pastikan permission REQUEST_INSTALL_PACKAGES sudah diberikan
2. Pada Android 8+, pengguna harus mengizinkan "Install unknown apps" untuk aplikasi Anda
3. Arahkan pengguna ke settings:
```dart
if (await updater.canRequestPackageInstalls()) {
  // Install
} else {
  // Arahkan ke settings untuk mengizinkan "Install unknown apps"
  await updater.openInstallSettings();
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

# Checksum Verification
## Untuk mengaktifkan verifikasi integritas APK:

1. Upload APK ke GitHub Release
2. Generate SHA256:
```bash
sha256sum app-release.apk > app-release.apk.sha256
```
3. Upload file checksum ke GitHub Release
4. Aktifkan di config:
```dart
verifyChecksum: true
```
Package akan otomatis:
 - Mendownload file app-release.apk.sha256
 - Menghitung SHA256 dari APK yang didownload
 - Membandingkan keduanya
 - Gagal jika tidak match
---

# 📄 Lisensi
---
Copyright © 2026 TuyulTronik
Dilisensikan di bawah MIT License.

---

# Additional information
- Repository : [https://github.com/TuyulTronik/flutter_apk_updater](https://github.com/TuyulTronik/flutter_apk_updater) 
- Inspired By : [github_release_apk_updater](https://github.com/TuyulTronik/flutter_apk_updater) 