package com.example.flutter_apk_updater

import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.plugin.common.MethodChannel

class ApkInstaller(
    private val context: Context,
) {

    private val fileProviderHelper = FileProviderHelper(context)

    fun install(
        apkPath: String,
        result: MethodChannel.Result,
    ) {
        try {
            val uri = fileProviderHelper.getApkUri(apkPath)

            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, APK_MIME_TYPE)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

                // ✅ Pindahkan conditional flag ke dalam apply block
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
                }
                  // ✅ Flag untuk clear task saat installer terbuka
              if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK)
                }
            }

            val packageManager = context.packageManager

            if (intent.resolveActivity(packageManager) == null) {
                result.error(
                    "activity_not_found",
                    "Tidak ada aplikasi yang dapat menginstall APK. " +
                    "Pastikan package installer tersedia.",
                    null,
                )
                return
            }

            context.startActivity(intent)
            result.success(null)

        } catch (exception: IllegalArgumentException) {
            result.error(
                "invalid_apk",
                "File APK tidak valid: ${exception.message}",
                null,
            )
        } catch (exception: SecurityException) {
            result.error(
                "security_error",
                "Error keamanan: ${exception.message}. " +
                "Pastikan permission sudah diberikan.",
                null
            )
        } catch (exception: Exception) {
            result.error(
                "install_failed",
                "Gagal install APK: ${exception.message}",
                null,
            )
        }
    }

    private companion object {
        const val APK_MIME_TYPE = "application/vnd.android.package-archive"
    }
}