# Changelog

## [1.0.2] - 2026-07-22

### ✨ Fitur Baru
- **Close App After Install**: Otomatis menutup aplikasi setelah instalasi APK selesai
  - Mencegah duplicate instance aplikasi di background
  - Dapat dikonfigurasi via `closeAppAfterInstall` (default: `true`)
  - Implementasi native menggunakan `finishAndRemoveTask()` + `System.exit(0)`

### 🔧 Perbaikan
- Tidak ada lagi 2 instance aplikasi yang running setelah native update
- Pengalaman instalasi APK lebih bersih

### 📚 Dokumentasi
- Update README dengan contoh penggunaan `closeAppAfterInstall`

## [1.0.1] - 2026-07-20

### ✨ Fitur Baru

#### Core Features
- **Check Update**: Cek update terbaru dari GitHub Releases
- **Download APK**: Download APK dengan progress tracking
- **Install APK**: Install APK secara otomatis
- **Private Repository**: Dukungan GitHub Token untuk private repo

#### Security (Fitur Optional)
- **APK Integrity**: Verifikasi checksum SHA256 (opsional)
  - Cari file `{apk_name}.apk.sha256` di GitHub Release
  - Verifikasi integritas APK sebelum install
  - Diaktifkan via config `verifyChecksum: true`

#### Performance & Reliability
- **Storage Check**: Cek ketersediaan storage sebelum download
- **Retry Mechanism**: Retry otomatis untuk network errors
  - Maksimal 3 kali percobaan
  - Delay tetap 2 detik
- **Timeout Configuration**: Konfigurasi timeout untuk network requests
- **Overwrite Strategy**: File APK lama dihapus sebelum download baru

#### User Experience
- **Permission Handling**: Runtime permission check untuk Android 8+
- **Settings Navigation**: Buka halaman settings untuk izin install
- **Auto Delete**: Konfigurasi `autoDeleteAfterInstall` (default: false)

#### Architecture Improvements
- **Dependency Injection**: Constructor injection untuk testing
- **Better Error Codes**: Error codes yang konsisten dan informatif
- **Improved Error Messages**: Pesan error yang jelas dalam Bahasa Indonesia

### 🏗️ Perubahan Arsitektur

#### File Structure
lib/src/
├── security/
│ └── checksum_verifier.dart # [BARU] Verifikasi SHA256
├── utils/
│ ├── storage_helper.dart # [BARU] Cek storage space
│ └── file_helper.dart # [BARU] Helper file operations

## [1.0.0] - 2026-07-18

### ✨ Fitur Baru
- Initial release
- Cek update dari GitHub Releases
- Download APK dengan progress tracking
- Install APK secara otomatis
- Dukungan private repository dengan GitHub Token
- Session download untuk resume
- Version comparison dengan SemVer
- Asset filtering berdasarkan pattern

### 🏗️ Arsitektur
- Platform Interface Pattern
- Result Pattern untuk error handling
- Service Layer Pattern
- Immutable Models

### 📱 Platform Support
- Android (API 24+)

### 🐛 Known Issues
- Permission `REQUEST_INSTALL_PACKAGES` harus diberikan secara manual
- Tidak mendukung version non-SemVer
- Belum ada fitur force update
- Belum ada cleanup untuk file APK lama
- Belum ada pengecekan storage space sebelum download

### 🔒 Security
- FileProvider untuk URI sharing
- Token GitHub disimpan di config (dikelola oleh pengguna)

---

## [Unreleased]

### 🔜 Rencana Fitur
- [ ] Auto-cleanup file APK lama
- [ ] Storage space check
- [ ] Force update configuration
- [ ] Download notification di background
- [ ] Unit tests & Integration tests
- [ ] Support version non-SemVer
- [ ] Permission handling otomatis

---

## 📦 Version History

| Version | Tanggal | Keterangan |
|---------|---------|------------|
| 1.0.0   | 2026-07-18 | Initial release |
| 1.0.1   | 2026-07-20 | Improvement |

