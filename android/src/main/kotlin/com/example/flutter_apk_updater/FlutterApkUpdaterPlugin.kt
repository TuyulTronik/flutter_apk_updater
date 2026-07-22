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
                   _closeAppWithRestart()
                    result.success(null)
             }
            else -> {
                result.notImplemented()
            }
        }
    }
  // ✅ METHOD BARU: Close app dengan restart intent (diadaptasi dari terminate_restart)
    private fun _closeAppWithRestart() {
        try {
            val currentActivity = activity
            if (currentActivity == null) {
                // Fallback: System.exit
                System.exit(0)
                return
            }

            // 1. Dapatkan package manager dan intent
            val packageManager = context.packageManager
            val packageName = context.packageName
            val launchIntent = packageManager.getLaunchIntentForPackage(packageName)

            if (launchIntent != null) {
                // 2. Buat restart intent (ini yang paling penting!)
                val mainIntent = Intent.makeRestartActivityTask(launchIntent.component)
                
                // 3. Start intent baru dengan delay (biar installer sempat terbuka)
                Handler(Looper.getMainLooper()).postDelayed({
                    try {
                        context.startActivity(mainIntent)
                        // 4. Exit proses lama
                        System.exit(0)
                    } catch (e: Exception) {
                        // Fallback
                        System.exit(0)
                    }
                }, 300) // 300ms cukup

            } else {
                // Fallback: finish activity + exit
                Handler(Looper.getMainLooper()).postDelayed({
                    currentActivity.finishAndRemoveTask()
                    System.exit(0)
                }, 300)
            }

        } catch (e: Exception) {
            // Ultimate fallback
            try {
                System.exit(0)
            } catch (_: Exception) {
                // Ignore
            }
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
    
    override fun onDetachedFromEngine(
        binding: FlutterPlugin.FlutterPluginBinding
    ) {
        channel.setMethodCallHandler(null)
    }
}