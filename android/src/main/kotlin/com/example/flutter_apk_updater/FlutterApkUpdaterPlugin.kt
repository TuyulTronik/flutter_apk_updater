package com.example.flutter_apk_updater

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.app.Activity
import android.os.Environment
import android.os.StatFs
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FlutterApkUpdaterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext

        channel = MethodChannel(
            binding.binaryMessenger,
            "flutter_apk_updater"
        )

        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        when (call.method) {

            "installApk" -> {
                val apkPath = call.argument<String>("apkPath")

                if (apkPath.isNullOrBlank()) {
                    result.error(
                        "invalid_argument",
                        "apkPath is required.",
                        null
                    )
                    return
                }

                // Cek permission untuk Android 8+ (API 26+)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    if (!context.packageManager.canRequestPackageInstalls()) {
                        result.error(
                            "permission_denied",
                            "Mohon izinkan instalasi dari sumber tidak dikenal di Settings > Apps > Special app access > Install unknown apps",
                            mapOf(
                                "needsPermission" to true,
                                "canRequest" to true,
                                "sdkVersion" to Build.VERSION.SDK_INT
                            )
                        )
                        return
                    }
                }

                ApkInstaller(context).install(
                    apkPath = apkPath,
                    result = result,
                )
            }

            "canRequestPackageInstalls" -> {
                val canRequest = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.packageManager.canRequestPackageInstalls()
                } else {
                    // Untuk Android 7- (API < 26), permission tidak diperlukan
                    true
                }
                result.success(canRequest)
            }

            "openInstallSettings" -> {
                try {
                    val intent = Intent(
                        Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                        Uri.parse("package:${context.packageName}")
                    )
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    context.startActivity(intent)
                    result.success(true)
                } catch (e: Exception) {
                    result.error(
                        "open_settings_failed",
                        "Gagal membuka halaman settings: ${e.message}",
                        null
                    )
                }
            }

            "getFreeSpace" -> {
                try {
                    // Gunakan context.filesDir untuk Android 10+
                    val path = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        context.filesDir.path // Lebih aman untuk Android 10+
                    } else {
                        Environment.getDataDirectory().path
                    }

                    val stat = StatFs(path)
                    val freeBytes = stat.availableBlocksLong * stat.blockSizeLong
                    result.success(freeBytes)
                } catch (e: Exception) {
                    result.error("storage_error", e.message, null)
                }
            }
             "closeApp" -> {
                    _closeApp()
                    result.success(null)
             }
            else -> {
                result.notImplemented()
            }
        }
    }
  private fun _closeApp() {
    try {
        val activity = context as? Activity
        
        // 1. Tutup semua aktivitas (biar keluar dari recent apps)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            activity?.finishAndRemoveTask()
        } else {
            activity?.finish()
        }
        
        // 2. ✅ Hentikan proses app setelah delay
        // Delay ini penting agar:
        // - Installer sempat terbuka
        // - Activity finish selesai
        Handler(Looper.getMainLooper()).postDelayed({
            try {
                // Method 1: System.exit (standar)
                System.exit(0)
            } catch (e: Exception) {
                // Method 2: Kill process (fallback)
                android.os.Process.killProcess(android.os.Process.myPid())
            }
        }, 500) // 500ms cukup
        
    } catch (e: Exception) {
        // Ultimate fallback: langsung exit
        try {
            System.exit(0)
        } catch (_: Exception) {
            android.os.Process.killProcess(android.os.Process.myPid())
        }
    }
}

    override fun onDetachedFromEngine(
        binding: FlutterPlugin.FlutterPluginBinding
    ) {
        channel.setMethodCallHandler(null)
    }
}