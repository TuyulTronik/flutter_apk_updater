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

---

# Features

## ✅ Implemented

- Check latest GitHub Release
- Semantic Version comparison
- APK asset selection menggunakan pattern
- Download APK menggunakan Dio Stream
- Download progress callback
- Session persistence menggunakan SharedPreferences
- Native Android APK Installer
- Result<T> based error handling
- MethodChannel integration
- Android FileProvider support

---

## ❌ Not Supported

- iOS
- Desktop
- Linux
- macOS
- Windows
- Background download
- Resume download
- Automatic update scheduling
- Delta / Patch update

---

## 🚧 Future

- Download resume
- Download verification (SHA256)
- Notification support
- Custom download directory
- Release channel (Stable/Beta)

---

# Screenshots

Coming Soon.

```
docs/images/
    banner.png
    screenshot_1.png
    screenshot_2.png
```

---

# Installation

```yaml
dependencies:
  flutter_apk_updater:
    ^1.0.0
```

---

# Quick Start

```dart
final updater = ApkUpdater(
  config: ApkUpdaterConfig(
    owner: 'owner',
    repository: 'repository',
    apkPattern: 'arm64-v8a',
  ),
);
```

---

# Usage

### 1. Create an updater instance

```dart
final updater = ApkUpdater(
  config: const ApkUpdaterConfig(
    owner: 'your-github-owner',
    repository: 'your-repository',
    apkPattern: 'app-release',
    githubToken: null, // Optional (private repository only)
  ),
);
```

---

### 2. Check for updates

```dart
final result = await updater.check();

if (result is Error<UpdateInfo>) {
  debugPrint(result.failure.message);
  return;
}

final update = (result as Success<UpdateInfo>).data;

if (!update.hasUpdate) {
  debugPrint('Application is already up to date.');
  return;
}
```

---

### 3. Download the APK

```dart
final downloadResult = await updater.download(
  updateInfo: update,
  onProgress: (progress) {
    debugPrint(
      '${(progress.progress * 100).toStringAsFixed(0)}%',
    );
  },
);
```

---

### 4. Install the downloaded APK

```dart
if (downloadResult is Success<DownloadInfo>) {
  await updater.install(
    apkPath: downloadResult.data.localFilePath,
  );
}
```

---
### Handling Result<T>

All public APIs return a `Result<T>` object.

```dart
final result = await updater.check();

switch (result) {
  case Success<UpdateInfo>():
    final update = result.data;
    break;

  case Error<UpdateInfo>():
    debugPrint(result.failure.message);
    break;
}
```
---
### Download Progress

A progress callback can be supplied while downloading.

```dart
await updater.download(
  updateInfo: update,
  onProgress: (progress) {
    print(
      '${progress.receivedBytes}/${progress.totalBytes}',
    );

    print(
      '${(progress.progress * 100).toStringAsFixed(1)}%',
    );
  },
);
```
---

### Complete Example

```dart
final updater = ApkUpdater(
  config: const ApkUpdaterConfig(
    owner: 'your-github-owner',
    repository: 'your-repository',
    apkPattern: 'app-release',
  ),
);

final checkResult = await updater.check();

if (checkResult is Error<UpdateInfo>) {
  debugPrint(checkResult.failure.message);
  return;
}

final update = (checkResult as Success<UpdateInfo>).data;

if (!update.hasUpdate) {
  debugPrint('Already using the latest version.');
  return;
}

final downloadResult = await updater.download(
  updateInfo: update,
  onProgress: (progress) {
    debugPrint(
      'Downloading ${(progress.progress * 100).toStringAsFixed(0)}%',
    );
  },
);

if (downloadResult is Error<DownloadInfo>) {
  debugPrint(downloadResult.failure.message);
  return;
}

await updater.install(
  apkPath: downloadResult.data.localFilePath,
);
```
---

# Download Flow

```text
Check Update
      │
      ▼
GitHub API
      │
      ▼
Latest Release
      │
      ▼
Select APK
      │
      ▼
Download
      │
      ▼
Progress
      │
      ▼
Completed
      │
      ▼
Android Installer
```

---

# Project Structure

```
lib/

android/

docs/
```

Detail struktur project tersedia pada:

- docs/project_structure.md

---

# Documentation

Dokumentasi teknis tersedia pada folder:

```
docs/
├── architecture.md
├── project_structure.md
├── public_api.md
├── download_lifecycle.md
├── github_release.md
├── error_handling.md
├── design_decisions.md
└── roadmap.md
```

---

# Roadmap

Lihat:

```
docs/roadmap.md
```

---

# License

MIT License.

---
# Additional information
- **Repository:[https://github.com/TuyulTronik/flutter_apk_updater](https://github.com/TuyulTronik/flutter_apk_updater) 
- **Inspired By :[github_release_apk_updater]