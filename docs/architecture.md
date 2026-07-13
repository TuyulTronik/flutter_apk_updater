# Architecture

## Overview

**flutter_apk_updater** dibangun menggunakan arsitektur modular berbasis tanggung jawab (Responsibility-based Modular Architecture).

Setiap komponen hanya memiliki satu tanggung jawab utama (Single Responsibility Principle), sehingga mudah dipelihara, diuji, dan dikembangkan tanpa memengaruhi komponen lain.

Package ini berfokus pada proses update aplikasi Android melalui GitHub Releases, mulai dari pengecekan versi hingga proses pengunduhan APK.

Diagram sederhana arsitektur package:

```text
                    Flutter Application
                            │
                            ▼
                      ApkUpdater
                            │
        ┌─────────────┬──────────────┬─────────────┐
        ▼             ▼              ▼             ▼
   GitHubApi   VersionComparator  AssetSelector  ApkDownloadService
                                                     │
                                                     ▼
                                           DownloadSessionStorage
                                                     │
                                                     ▼
                                               SharedPreferences

                            │
                            ▼
                      UpdateInstaller
                            │
                            ▼
                    Flutter Platform API
                            │
                            ▼
                      MethodChannel
                            │
                            ▼
                    Android Native Plugin
                            │
                            ▼
                      APK Installer
```

---

# Update Flow

Seluruh proses update mengikuti alur berikut.

```text
Application
      │
      ▼
ApkUpdater.check()
      │
      ▼
GitHubApi
      │
      ▼
GitHub Release
      │
      ▼
VersionComparator
      │
      ▼
AssetSelector
      │
      ▼
UpdateInfo
```

Apabila tersedia pembaruan, aplikasi dapat melanjutkan ke proses download.

---

# Download Flow

```text
Application
      │
      ▼
ApkUpdater.download()
      │
      ▼
ApkDownloadService
      │
      ▼
GitHub Asset Stream
      │
      ▼
Write APK File
      │
      ▼
Update Download Session
      │
      ▼
DownloadInfo Progress
      │
      ▼
Success
```

Download dilakukan menggunakan HTTP Stream melalui package Dio sehingga progress dapat dipantau secara real-time.

---

# Installation Flow

Setelah proses download selesai, instalasi APK dilakukan melalui implementasi native Android.

```text
Application
      │
      ▼
UpdateInstaller
      │
      ▼
Platform Interface
      │
      ▼
MethodChannel
      │
      ▼
FlutterApkUpdaterPlugin
      │
      ▼
ApkInstaller
      │
      ▼
Android Package Installer
```

Seluruh proses instalasi dijalankan melalui MethodChannel sehingga kode Dart tetap terpisah dari implementasi Android.

---

# Layer Responsibilities

## Public API

Merupakan titik masuk utama package.

Komponen:

```text
ApkUpdater
ApkUpdaterConfig
```

Tanggung jawab:

- menyediakan API yang digunakan aplikasi
- mengoordinasikan proses update
- menyembunyikan implementasi internal package

---

## API Layer

Bertanggung jawab melakukan komunikasi dengan GitHub REST API.

Komponen:

```text
GitHubApi
```

Responsibility:

- membangun endpoint
- mengirim HTTP request
- memproses response
- memetakan network error menjadi `Failure`

Layer ini tidak memiliki business logic update.

---

## Version Layer

Bertanggung jawab membandingkan semantic version.

Komponen:

```text
VersionComparator
```

Responsibility:

- normalisasi versi
- validasi semantic version
- membandingkan versi aplikasi dengan versi terbaru

---

## Asset Selection Layer

Bertanggung jawab memilih file APK yang sesuai.

Komponen:

```text
AssetSelector
```

Responsibility:

- mencari asset berdasarkan `apkPattern`
- memastikan asset APK tersedia pada GitHub Release

---

## Download Layer

Bertanggung jawab mengunduh APK.

Komponen:

```text
ApkDownloadService
```

Responsibility:

- membuat file download
- membaca HTTP stream
- melaporkan progress
- menyimpan metadata download
- menangani cancel download
- menghapus file ketika terjadi kegagalan

Layer ini tidak melakukan pengecekan update maupun instalasi APK.

---

## Session Layer

Bertanggung jawab menyimpan metadata download.

Komponen:

```text
DownloadSessionStorage
```

Responsibility:

- save
- load
- exists
- clear

Session hanya digunakan sebagai metadata proses download.

Package saat ini **tidak mengimplementasikan Resume Download**.

---

## Platform Layer

Menjadi jembatan antara Flutter dan Android.

Komponen:

```text
FlutterApkUpdaterPlatform
MethodChannelFlutterApkUpdater
```

Responsibility:

- mendefinisikan platform interface
- mengirim perintah install APK ke Android Native

---

## Android Native Layer

Berisi implementasi Android menggunakan Kotlin.

Komponen utama:

```text
FlutterApkUpdaterPlugin
```

Sebagai penghubung MethodChannel.

```text
ApkInstaller
```

Menjalankan Android Package Installer.

```text
FileProviderHelper
```

Menghasilkan URI yang aman menggunakan FileProvider.

---

# Dependency Flow

Seluruh dependency mengikuti arah satu arah (one-way dependency).

```text
Application
      │
      ▼
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
                     │
                     ▼
            SharedPreferences
```

Platform layer berada di luar dependency graph Dart.

```text
Flutter
     │
     ▼
Platform Interface
     │
     ▼
MethodChannel
     │
     ▼
Android Plugin
```

Dependency selalu mengarah ke bawah.

Tidak ada komponen yang memiliki circular dependency.

---

# Data Flow

Data mengalir secara bertahap dari GitHub hingga menjadi informasi yang dapat digunakan aplikasi.

```text
GitHub API
      │
      ▼
GitHubRelease
      │
      ▼
VersionComparator
      │
      ▼
AssetSelector
      │
      ▼
UpdateInfo
      │
      ▼
Application
```

Sedangkan proses download mengikuti alur berikut.

```text
GitHub Asset
      │
      ▼
HTTP Stream
      │
      ▼
APK File
      │
      ▼
DownloadInfo
      │
      ▼
Application
```

---

# Error Handling

Seluruh operasi yang dapat gagal mengembalikan:

```text
Result<T>
```

yang terdiri dari:

```text
Success<T>
```

atau

```text
Error<T>
```

Seluruh informasi kegagalan direpresentasikan menggunakan model:

```text
Failure
```

Pendekatan ini memberikan mekanisme penanganan error yang konsisten di seluruh package.

---

# Design Principles

Package dikembangkan berdasarkan prinsip-prinsip berikut.

- Single Responsibility Principle (SRP)
- Separation of Concerns
- Composition over Inheritance
- Dependency Injection pada komponen yang dapat diganti
- Provider Independent
- Android APK Only
- GitHub Release Only
- Public API yang sederhana dan stabil
- Seluruh operasi menggunakan `Result<T>` untuk penanganan hasil yang konsisten
- Arsitektur modular berbasis tanggung jawab