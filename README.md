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

    // Close app setelah install (default: true)
    closeAppAfterInstall: true,
  ),
  
  // Optional: Timeout untuk network requests
  timeout: Duration(seconds: 60),
);
```
### Close App After Install

Setelah instalasi APK selesai, aplikasi akan otomatis ditutup untuk mencegah **duplicate instance** di background.

```dart
final updater = ApkUpdater(
  config: ApkUpdaterConfig(
    owner: 'TuyulTronik',
    repository: 'tulkit',
    apkPattern: 'release',
    closeAppAfterInstall: true, // ✅ Default: true (otomatis close)
  ),
);
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
---

# 📝 Menampilkan Changelog / Release Notes
---

Package ini menyediakan akses ke release notes (changelog) dari GitHub Release. Berikut adalah berbagai cara untuk menampilkannya:

## Opsi 1: Menampilkan Changelog dalam Dialog

Tampilkan changelog dalam dialog sebelum user melakukan download:

```dart
Future<void> showUpdateDialog(BuildContext context, UpdateInfo updateInfo) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Update Tersedia'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Versi: ${updateInfo.latestVersion}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'Riwayat Perubahan:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              updateInfo.release.releaseNotes.isEmpty 
                ? 'Tidak ada catatan perubahan' 
                : updateInfo.release.releaseNotes,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'Dirilis: ${updateInfo.release.publishedAt.toLocal()}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Tidak Sekarang'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Lanjutkan ke download
          },
          child: Text('Update Sekarang'),
        ),
      ],
    ),
  );
}
```

### Penggunaan:
```dart
final checkResult = await updater.check();

if (checkResult.isSuccess) {
  final updateInfo = (checkResult as Success<UpdateInfo>).data;
  
  if (updateInfo.hasUpdate && mounted) {
    await showUpdateDialog(context, updateInfo);
  }
}
```

---

## Opsi 2: Menampilkan Changelog dalam Bottom Sheet

Untuk tampilan yang lebih fleksibel, gunakan bottom sheet:

```dart
Future<void> showUpdateBottomSheet(BuildContext context, UpdateInfo updateInfo) {
  return showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Update Aplikasi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVersionInfo(updateInfo),
                  SizedBox(height: 16),
                  _buildReleaseNotes(updateInfo),
                ],
              ),
            ),
          ),
          Divider(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Lanjutkan ke download
              },
              child: Text('Download & Install'),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildVersionInfo(UpdateInfo updateInfo) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Versi Baru: ${updateInfo.latestVersion}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 4),
        Text(
          'Versi Saat Ini: ${updateInfo.currentVersion}',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        SizedBox(height: 4),
        Text(
          'Dirilis: ${formatDate(updateInfo.release.publishedAt)}',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    ),
  );
}

Widget _buildReleaseNotes(UpdateInfo updateInfo) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Perubahan:',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      SizedBox(height: 8),
      Text(
        updateInfo.release.releaseNotes.isEmpty
            ? '• Tidak ada catatan perubahan\n\nPastikan repository GitHub Anda memiliki release notes yang terisi.'
            : updateInfo.release.releaseNotes,
        style: TextStyle(fontSize: 13, height: 1.6),
      ),
    ],
  );
}

String formatDate(DateTime date) {
  // Format: "23 Juli 2026 pukul 14:30"
  final months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  final localDate = date.toLocal();
  return '${localDate.day} ${months[localDate.month - 1]} ${localDate.year} '
      'pukul ${localDate.hour.toString().padLeft(2, '0')}:'
      '${localDate.minute.toString().padLeft(2, '0')}';
}
```

---

## Opsi 3: Custom Widget untuk Changelog

Buat widget yang reusable untuk menampilkan changelog dengan styling kustom:

```dart
class ChangelogWidget extends StatelessWidget {
  final UpdateInfo updateInfo;
  final VoidCallback onUpdatePressed;

  const ChangelogWidget({
    required this.updateInfo,
    required this.onUpdatePressed,
  });

  @override
  Widget build(BuildContext context) {
    final releaseNotes = updateInfo.release.releaseNotes;
    final formattedNotes = _parseReleaseNotes(releaseNotes);

    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Update Tersedia',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${updateInfo.currentVersion} → ${updateInfo.latestVersion}',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perubahan Terbaru:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 12),
                ...formattedNotes.map((note) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(note, style: TextStyle(fontSize: 13))),
                    ],
                  ),
                )),
                SizedBox(height: 8),
                Text(
                  'Dirilis: ${formatDate(updateInfo.release.publishedAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Divider(height: 0),
          Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpdatePressed,
                child: Text('Update Sekarang'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Parse release notes menjadi list of strings
  /// Mendukung format:
  /// - Bullet points dengan "-" atau "•"
  /// - Numbered lists dengan "1."
  /// - Paragraphs yang dipisah dengan newline
  List<String> _parseReleaseNotes(String notes) {
    if (notes.isEmpty) {
      return ['Tidak ada catatan perubahan'];
    }

    final lines = notes.split('\n');
    final parsedNotes = <String>[];

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Hapus bullet points atau numbering
      final cleaned = trimmed
          .replaceFirst(RegExp(r'^[-•]\s*'), '')
          .replaceFirst(RegExp(r'^\d+\.\s*'), '');

      if (cleaned.isNotEmpty) {
        parsedNotes.add(cleaned);
      }
    }

    return parsedNotes.isEmpty ? ['Tidak ada catatan perubahan'] : parsedNotes;
  }
}
```

### Penggunaan:
```dart
ChangelogWidget(
  updateInfo: updateInfo,
  onUpdatePressed: () {
    // Trigger download
  },
)
```

---

## Opsi 4: Ekstrak Changelog Tertentu

Jika Anda ingin menampilkan hanya bagian tertentu dari release notes:

```dart
class ChangelogParser {
  /// Ekstrak changelog dari format markdown yang umum
  /// Format yang didukung:
  /// ## Features
  /// - Fitur 1
  /// - Fitur 2
  /// ## Bug Fixes
  /// - Bug 1
  /// - Bug 2
  static Map<String, List<String>> parseMarkdownChangelog(String notes) {
    final sections = <String, List<String>>{};
    final lines = notes.split('\n');
    
    String? currentSection;
    List<String> currentItems = [];

    for (var line in lines) {
      final trimmed = line.trim();

      // Deteksi section header (## atau ###)
      if (trimmed.startsWith('##')) {
        if (currentSection != null && currentItems.isNotEmpty) {
          sections[currentSection] = currentItems;
        }
        currentSection = trimmed
            .replaceFirst(RegExp(r'^#+\s*'), '')
            .trim();
        currentItems = [];
        continue;
      }

      // Deteksi items dalam section (- atau •)
      if (trimmed.startsWith('-') || trimmed.startsWith('•')) {
        final item = trimmed
            .replaceFirst(RegExp(r'^[-•]\s*'), '')
            .trim();
        if (item.isNotEmpty) {
          currentItems.add(item);
        }
      }
    }

    // Tambahkan section terakhir
    if (currentSection != null && currentItems.isNotEmpty) {
      sections[currentSection] = currentItems;
    }

    return sections;
  }

  /// Extract changelog terstruktur dengan kategori
  static StructuredChangelog parse(String notes) {
    final sections = parseMarkdownChangelog(notes);

    return StructuredChangelog(
      features: sections['Features'] ?? [],
      bugFixes: sections['Bug Fixes'] ?? sections['Bug Fixes'] ?? [],
      improvements: sections['Improvements'] ?? sections['Improvements'] ?? [],
      breaking: sections['Breaking Changes'] ?? [],
      other: sections['Other Changes'] ?? [],
    );
  }
}

class StructuredChangelog {
  final List<String> features;
  final List<String> bugFixes;
  final List<String> improvements;
  final List<String> breaking;
  final List<String> other;

  StructuredChangelog({
    required this.features,
    required this.bugFixes,
    required this.improvements,
    required this.breaking,
    required this.other,
  });

  bool get hasContent =>
      features.isNotEmpty ||
      bugFixes.isNotEmpty ||
      improvements.isNotEmpty ||
      breaking.isNotEmpty ||
      other.isNotEmpty;
}

// Penggunaan:
class StructuredChangelogWidget extends StatelessWidget {
  final UpdateInfo updateInfo;

  const StructuredChangelogWidget({required this.updateInfo});

  @override
  Widget build(BuildContext context) {
    final changelog =
        ChangelogParser.parse(updateInfo.release.releaseNotes);

    return ListView(
      children: [
        if (changelog.breaking.isNotEmpty)
          _buildSection('⚠️ Breaking Changes', changelog.breaking, Colors.red),
        if (changelog.features.isNotEmpty)
          _buildSection('✨ Fitur Baru', changelog.features, Colors.green),
        if (changelog.improvements.isNotEmpty)
          _buildSection('🚀 Perbaikan', changelog.improvements, Colors.blue),
        if (changelog.bugFixes.isNotEmpty)
          _buildSection('🐛 Perbaikan Bug', changelog.bugFixes, Colors.orange),
        if (changelog.other.isNotEmpty)
          _buildSection('📝 Lainnya', changelog.other, Colors.grey),
      ],
    );
  }

  Widget _buildSection(
    String title,
    List<String> items,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
          SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: EdgeInsets.only(left: 16, bottom: 4),
            child: Text('• $item', style: TextStyle(fontSize: 13)),
          )),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
```

---

## Opsi 5: Implementasi Lengkap dengan UpdateInfo

Berikut adalah implementasi lengkap yang menggabungkan semuanya:

```dart
class UpdateCheckPage extends StatefulWidget {
  const UpdateCheckPage({Key? key}) : super(key: key);

  @override
  State<UpdateCheckPage> createState() => _UpdateCheckPageState();
}

class _UpdateCheckPageState extends State<UpdateCheckPage> {
  late ApkUpdater _updater;
  UpdateInfo? _updateInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUpdater();
  }

  void _initializeUpdater() {
    _updater = ApkUpdater(
      config: const ApkUpdaterConfig(
        owner: 'TuyulTronik',
        repository: 'my_app',
        apkPattern: 'app-release',
      ),
    );
  }

  Future<void> _checkForUpdates() async {
    setState(() => _isLoading = true);

    try {
      final result = await _updater.check();

      if (result.isSuccess) {
        final updateInfo = (result as Success<UpdateInfo>).data;

        setState(() => _updateInfo = updateInfo);

        if (updateInfo.hasUpdate && mounted) {
          _showUpdateDialog(updateInfo);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Aplikasi sudah versi terbaru')),
          );
        }
      } else {
        final failure = (result as Error<UpdateInfo>).failure;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showUpdateDialog(UpdateInfo updateInfo) async {
    final shouldUpdate = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildUpdateDialog(updateInfo),
    );

    if (shouldUpdate == true && mounted) {
      _downloadAndInstall(updateInfo);
    }
  }

  Widget _buildUpdateDialog(UpdateInfo updateInfo) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.system_update, color: Colors.blue),
          SizedBox(width: 8),
          Text('Update Tersedia'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Versi Saat Ini'),
                      Text(
                        updateInfo.currentVersion,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Versi Baru'),
                      Text(
                        updateInfo.latestVersion,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Perubahan:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              updateInfo.release.releaseNotes.isEmpty
                  ? 'Tidak ada catatan perubahan'
                  : updateInfo.release.releaseNotes,
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 8),
            Text(
              'Dirilis: ${formatDate(updateInfo.release.publishedAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Nanti'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Update Sekarang'),
        ),
      ],
    );
  }

  Future<void> _downloadAndInstall(UpdateInfo updateInfo) async {
    // Implementation download dan install
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Checker')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _checkForUpdates,
          icon: Icon(Icons.refresh),
          label: Text(_isLoading ? 'Checking...' : 'Check Updates'),
        ),
      ),
    );
  }
}
```

---

## Format Release Notes yang Disarankan

Untuk hasil maksimal, gunakan format markdown ini di GitHub Release:

```markdown
## ✨ Fitur Baru
- Login dengan Face ID
- Dark mode support
- New dashboard UI

## 🚀 Perbaikan
- Performa aplikasi meningkat 30%
- Optimisasi memory usage
- Faster app startup

## 🐛 Bug Fixes
- Fix crash pada Android 10
- Fix duplicate notification issue
- Fix upload file problem

## ⚠️ Breaking Changes
- Android minimum API 21 → 24
- Migration database required

## 📝 Lainnya
- Update dependencies
- Code cleanup
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
    this.verifyChecksum = false,
    this.autoDeleteAfterInstall = false,
    this.closeAppAfterInstall = true,          
    
  });
}
```
| Parameter | Type | Deskripsi |
|---------|--------|----------|
| owner | String| Username atau organisasi GitHub |
| repository | String| Nama repository GitHub |
| apkPattern | String| Pattern untuk memilih asset APK (contoh: 'app-release') |
| githubToken | String?| Token GitHub untuk akses private repository |
| verifyChecksum | bool| Verifikasi checksum SHA256 (APK Integrity) |
| autoDeleteAfterInstall | bool| delete Apk update setelah instalasi selesai (saving storage) |
| closeAppAfterInstall | bool| Tutup app setelah install APK (mencegah duplicate instance) |


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
> **Catatan**: Untuk contoh implementasi yang lebih lengkap bisa cek **example** dalam repository.

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