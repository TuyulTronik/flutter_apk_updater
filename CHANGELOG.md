# Changelog

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