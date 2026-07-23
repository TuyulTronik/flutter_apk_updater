package com.example.flutter_apk_updater

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FlutterApkUpdaterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null

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
                    true
                }
                result.success(canRequest)
            }

            "openInstallSettings" -> {
                try {
                    val intent = Intent(
                        android.provider.Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                        android.net.Uri.parse("package:${context.packageName}")
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
                    val path = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        context.filesDir.path
                    } else {
                        android.os.Environment.getDataDirectory().path
                    }

                    val stat = android.os.StatFs(path)
                    val freeBytes = stat.availableBlocksLong * stat.blockSizeLong
                    result.success(freeBytes)
                } catch (e: Exception) {
                    result.error("storage_error", e.message, null)
                }
            }

            "closeApp" -> {
                _closeAppWithDelay()
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * Menutup aplikasi dengan delay agar installer terbuka terlebih dahulu.
     * 
     * Flow:
     * 1. Delay 1200ms (tunggu installer terbuka)
     * 2. Hapus app dari recent apps (finishAndRemoveTask)
     * 3. Delay 300ms (tunggu proses finish selesai)
     * 4. Hentikan proses app (System.exit / Process.killProcess)
     * 
     * Hasil: Recent apps hanya menampilkan 1 entri (app versi baru)
     */
    private fun _closeAppWithDelay() {
        try {
            val currentActivity = activity
            if (currentActivity == null) {
                System.exit(0)
                return
            }

            // Step 1: Tunggu installer terbuka (1200ms)
            Handler(Looper.getMainLooper()).postDelayed({
                try {
                    // Step 2: Hapus dari recent apps
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        currentActivity.finishAndRemoveTask()
                    } else {
                        currentActivity.finish()
                    }

                    // Step 3: Tunggu proses finish selesai (300ms)
                    Handler(Looper.getMainLooper()).postDelayed({
                        try {
                            // Step 4: Hentikan proses app
                            System.exit(0)
                        } catch (e: Exception) {
                            try {
                                android.os.Process.killProcess(android.os.Process.myPid())
                            } catch (_: Exception) {
                                // Ignore
                            }
                        }
                    }, 300)

                } catch (e: Exception) {
                    // Fallback: langsung exit
                    System.exit(0)
                }
            }, 1200) // ← Optimal: 1200ms

        } catch (e: Exception) {
            // Ultimate fallback
            System.exit(0)
        }
    }

    // ============================================================
    // ActivityAware Implementation
    // ============================================================
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}