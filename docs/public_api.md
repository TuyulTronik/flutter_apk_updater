# Public API

Package ini memiliki API publik yang sengaja dibuat seminimal mungkin.

---

# ApkUpdater

Entry point utama package.

```dart
final updater = ApkUpdater(
  config: ApkUpdaterConfig(...),
);
```

Method:

- check()
- download()

---

# ApkUpdaterConfig

Digunakan untuk mengonfigurasi repository GitHub.

Parameter

| Property    | Required | Description           |
|-------------|----------|-----------------------|
| owner       | Yes      | GitHub owner          |
| repository  | Yes      | Repository name       |
| apkPattern  | Yes      | APK asset pattern     |
| githubToken | No       | Personal Access Token |

---

# UpdateInstaller

Memanggil installer Android native.

```dart
await UpdateInstaller().install(
    apkPath: ...
);
```

---

# Result<T>

Semua operasi asynchronous mengembalikan Result.

```
Success<T>

Error<T>
```

Tidak menggunakan Exception sebagai return value.

---

# Models

DownloadInfo

UpdateInfo

GitHubRelease

GitHubAsset