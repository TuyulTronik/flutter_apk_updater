package com.example.flutter_apk_updater

import android.content.Context
import android.content.Intent
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

            val uri = fileProviderHelper.getApkUri(
                apkPath,
            )

            val intent = Intent(Intent.ACTION_VIEW).apply {

                setDataAndType(
                    uri,
                    APK_MIME_TYPE,
                )

                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

            }

            val packageManager = context.packageManager

            if (intent.resolveActivity(packageManager) == null) {

                result.error(
                    "activity_not_found",
                    "No activity found to install APK.",
                    null,
                )

                return

            }

            context.startActivity(intent)

            result.success(null)

        } catch (exception: IllegalArgumentException) {

            result.error(
                "invalid_apk",
                exception.message,
                null,
            )

        } catch (exception: Exception) {

            result.error(
                "install_failed",
                exception.message,
                null,
            )

        }

    }

    private companion object {

        const val APK_MIME_TYPE =
            "application/vnd.android.package-archive"

    }

}