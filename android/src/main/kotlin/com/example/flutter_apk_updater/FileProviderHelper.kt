package com.example.flutter_apk_updater

import android.content.Context
import android.net.Uri
import androidx.core.content.FileProvider
import java.io.File

class FileProviderHelper(
    private val context: Context,
) {

    fun getApkUri(
        apkPath: String,
    ): Uri {

        val file = File(apkPath)

        if (!file.exists()) {
            throw IllegalArgumentException(
                "APK file does not exist: $apkPath",
            )
        }

        if (!file.isFile) {
            throw IllegalArgumentException(
                "Path is not a file: $apkPath",
            )
        }

        if (!file.canRead()) {
            throw IllegalArgumentException(
                "APK file cannot be read: $apkPath",
            )
        }

        return FileProvider.getUriForFile(
            context,
            "${context.packageName}.flutter_apk_updater.fileprovider",
            file,
        )
    }
}