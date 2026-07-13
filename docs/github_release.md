# GitHub Release

Package ini mengambil APK dari GitHub Releases.

Repository harus memiliki Release.

Contoh

```
v1.0.0
```

Asset

```
app-arm64-v8a.apk

app-armeabi-v7a.apk
```

Kemudian

```dart
apkPattern:
```

akan memilih asset berdasarkan nama file.

Contoh

```
apkPattern = arm64-v8a
```

akan memilih

```
myapp-arm64-v8a.apk
```

Jika asset tidak ditemukan maka package mengembalikan

```
asset.not_found
```