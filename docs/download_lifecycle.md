# Download Lifecycle

```
Check Update
      │
      ▼
GitHub Release
      │
      ▼
Select Asset
      │
      ▼
Download APK
      │
      ▼
Save Session
      │
      ▼
Progress Callback
      │
      ▼
Completed
      │
      ▼
Install APK
```

---

## Check Update

Mengambil release terbaru dari GitHub.

---

## Asset Selection

Asset dipilih menggunakan apkPattern.

---

## Download

Menggunakan Dio Stream.

---

## Progress

Progress diberikan melalui callback.

---

## Session

Progress download disimpan menggunakan SharedPreferences.

---

## Installation

APK diinstall menggunakan MethodChannel.