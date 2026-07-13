# Design Decisions

## Mengapa menggunakan Result<T>

Menghindari Exception sebagai flow control.

Semua operasi asynchronous mengembalikan Result.

---

## Mengapa menggunakan Dio

Karena mendukung stream download.

---

## Mengapa menggunakan SharedPreferences

Karena session download hanya berupa metadata kecil.

Tidak memerlukan database.

---

## Mengapa menggunakan MethodChannel

Instalasi APK hanya dapat dilakukan melalui Android native.

---

## Mengapa package Android only

Karena instalasi APK hanya tersedia pada Android.

Platform lain tidak mendukung konsep APK.