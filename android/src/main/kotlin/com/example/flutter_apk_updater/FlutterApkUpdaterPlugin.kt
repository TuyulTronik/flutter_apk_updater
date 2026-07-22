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
                // ✅ Panggil close dengan delay lebih panjang
                _closeAppWithDelay()
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    // ✅ METHOD CLOSE APP DENGAN DELAY 1500ms
    private fun _closeAppWithDelay() {
        try {
            val currentActivity = activity
            if (currentActivity == null) {
                System.exit(0)
                return
            }

            // ✅ Delay 1500ms agar installer benar-benar terbuka dan app lama siap ditutup
            Handler(Looper.getMainLooper()).postDelayed({
                try {
                    // 1. Hapus dari recent apps
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        currentActivity.finishAndRemoveTask()
                    } else {
                        currentActivity.finish()
                    }

                    // 2. Hentikan proses
                    Handler(Looper.getMainLooper()).postDelayed({
                        try {
                            System.exit(0)
                        } catch (e: Exception) {
                            try {
                                android.os.Process.killProcess(android.os.Process.myPid())
                            } catch (_: Exception) {}
                        }
                    }, 300)

                } catch (e: Exception) {
                    System.exit(0)
                }
            }, 1500) // ← Delay 1.5 detik

        } catch (e: Exception) {
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