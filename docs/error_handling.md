# Error Handling

Semua operasi menggunakan Result<T>.

Tidak melempar exception ke caller.

---

| Code | Meaning |
|-------|----------|
| github.network | Network error |
| github.not_found | Repository tidak ditemukan |
| github.invalid_response | Response invalid |
| asset.not_found | Asset tidak ditemukan |
| version.invalid | Semantic version salah |
| download.failed | Download gagal |
| download.invalid_response | Download response invalid |
| platform.install_failed | Native installer gagal |
| updater.check_failed | Check update gagal |