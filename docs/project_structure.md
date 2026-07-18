# Project Structure

Berikut struktur folder utama package.

```text
flutter_apk_updater/
│
├── android/
│   └── src/
│       └── main/
│           ├── kotlin/
│           │   └── com/
│           │       └── example/
│           │           └── flutter_apk_updater/
│           │               ├── ApkInstaller.kt
│           │               ├── FileProviderHelper.kt
│           │               └── FlutterApkUpdaterPlugin.kt
│           │
│           ├── res/
│           │   └── xml/
│           │       └── flutter_apk_updater_paths.xml
│           │
│           └── AndroidManifest.xml
│
├── lib/
│   ├── flutter_apk_updater.dart
│   ├── flutter_apk_updater_method_channel.dart
│   ├── flutter_apk_updater_platform_interface.dart
│   │
│   └── src/
│       ├── api/
│       │    └── github_api.dart
│       ├── config/
│       │    └── apk_updater_config.dart
│       ├── downloader/
│       │    └── apk_downloader.dart
│       ├── installer/
│       │    └── update_installer.dart
│       ├── models/
│       │    ├── download_info.dart
│       │    ├── download_session.dart
│       │    ├── failure.dart
│       │    ├── github_asset.dart
│       │    ├── github_release.dart
│       │    ├── result.dart
│       │    └── update_info.dart
│       ├── session/
│       │    └── download_session_storage.dart
│       ├── updater/
│       │    ├── apk_updater.dart
│       │    └── asset_selector.dart
│       └── version/
│            └── version_comparator.dart
│
├── example/
├── docs/
├── CHANGELOG.md
├── LICENSE
├── README.md
└── pubspec.yaml
```

---

# Folder Overview

## lib/

Berisi seluruh implementasi package yang akan digunakan oleh aplikasi Flutter.

Package hanya mengekspor Public API melalui:

```text
flutter_apk_updater.dart
```

Seluruh implementasi internal berada di dalam folder `src/`.

---

## src/

Berisi seluruh implementasi internal package.

Struktur dipisahkan berdasarkan tanggung jawab (responsibility), bukan berdasarkan layer UI karena package ini bukan aplikasi.

```text
src/
    api/
    config/
    downloader/
    models/
    session/
    updater/
    version/
```

---

## api/

Berisi komunikasi dengan GitHub REST API.

Saat ini hanya memiliki satu responsibility:

```text
GitHub API
        │
        ▼
Latest Release
```

Class utama:

```text
GitHubApi
```

Bertanggung jawab untuk:

- membangun endpoint GitHub
- mengirim HTTP request
- mengubah response menjadi model
- memetakan network error menjadi `Failure`

Folder ini tidak memiliki business logic update.

---

## config/

Berisi konfigurasi package.

Saat ini terdiri dari:

```text
ApkUpdaterConfig
```

Konfigurasi ini digunakan sebagai sumber informasi untuk:

- owner repository
- repository
- apkPattern
- GitHub Personal Access Token (opsional)

---

## downloader/

Berisi implementasi proses download APK.

Class utama:

```text
ApkDownloadService
```

Responsibility:

- membuat file download
- mengunduh APK
- progress callback
- cancel download
- menyimpan download session
- menghapus file ketika terjadi error
- mengembalikan Result<DownloadInfo>

Folder ini **tidak** melakukan:

- update checking
- version comparison
- APK installation
- resume download

---

## models/

Berisi seluruh model yang digunakan package.

```text
DownloadInfo
DownloadSession
Failure
GitHubAsset
GitHubRelease
Result<T>
UpdateInfo
```

Model hanya merepresentasikan data.

Model tidak mengandung business logic.

---

## session/

Berisi penyimpanan Download Session.

Class:

```text
DownloadSessionStorage
```

Responsibility:

- save()
- load()
- exists()
- clear()

Session digunakan sebagai metadata proses download.

Package **tidak** mendukung Resume Download.

---

## updater/

Merupakan entry point utama business logic package.

Class:

```text
ApkUpdater
AssetSelector
```

Responsibility:

- check update
- version comparison
- asset selection
- memanggil downloader

Folder ini menjadi facade yang digunakan oleh aplikasi.

---

## version/

Berisi utilitas untuk membandingkan semantic version.

Class:

```text
VersionComparator
```

Menggunakan package:

```text
pub_semver
```

Responsibility:

- normalize version
- compare version
- determine update availability

---

## android/

Berisi implementasi native Android.

Package menggunakan MethodChannel untuk menjalankan proses instalasi APK.

Komponen utama:

```text
FlutterApkUpdaterPlugin.kt
```

Sebagai bridge antara Flutter dan Android.

```text
ApkInstaller.kt
```

Menjalankan Intent installer Android.

```text
FileProviderHelper.kt
```

Membuat URI yang aman menggunakan FileProvider.

```text
flutter_apk_updater_paths.xml
```

Konfigurasi FileProvider path.

---

## docs/

Berisi dokumentasi teknis yang lebih rinci.

README hanya memberikan gambaran umum dan merujuk ke folder ini untuk penjelasan mendalam.

Contoh:

```text
architecture.md
project_structure.md
public_api.md
download_lifecycle.md
github_release.md
error_handling.md
design_decisions.md
roadmap.md
```

---

## example/

Berisi contoh penggunaan package.

Folder ini digunakan sebagai referensi implementasi bagi pengguna package.

---

# Package Entry Flow

Package digunakan melalui class:

```text
ApkUpdater
```

Alur sederhananya:

```text
Application
      │
      ▼
ApkUpdater
      │
      ├───────────────┐
      ▼               ▼
GitHubApi      VersionComparator
      │               │
      └───────┬───────┘
              ▼
        AssetSelector
              ▼
     ApkDownloadService
              ▼
     Android Installer
```

---

# Dependency Flow

Seluruh dependency mengikuti arah satu arah (one-way dependency).

```text
ApkUpdater
      │
      ├────────► GitHubApi
      │
      ├────────► VersionComparator
      │
      ├────────► AssetSelector
      │
      └────────► ApkDownloadService
                        │
                        ▼
              DownloadSessionStorage
```

Native layer berada di luar dependency graph Dart.

```text
Flutter
    │
    ▼
MethodChannel
    │
    ▼
Android Plugin
    │
    ▼
APK Installer
```

---

# Design Principles

Project mengikuti beberapa prinsip desain utama.

- Single Responsibility Principle (SRP)
- Composition over Inheritance
- Dependency Injection untuk komponen yang dapat diganti
- Provider Independent
- Android APK Only
- GitHub Release Only
- Result<T> sebagai standar hasil operasi
- Separation of Concerns

Setiap folder memiliki satu tanggung jawab utama sehingga perubahan pada satu komponen tidak memengaruhi komponen lainnya.

---

# Naming Convention

Project mengikuti pola penamaan yang konsisten.

```text
*_api.dart
*_config.dart
*_service.dart
*_storage.dart
*_comparator.dart
*_selector.dart
*_info.dart
*_release.dart
*_asset.dart
```

Native Android mengikuti konvensi Kotlin:

```text
*Plugin.kt
*Installer.kt
*Helper.kt
```

Dengan struktur ini, package tetap modular, mudah dipelihara, dan mudah dikembangkan tanpa mengubah arsitektur yang telah ditetapkan.