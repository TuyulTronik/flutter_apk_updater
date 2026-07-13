package com.example.flutter_apk_updater

import android.content.Context
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

                ApkInstaller(context).install(
                    apkPath = apkPath,
                    result = result,
                )
            }

            else -> {

                result.notImplemented()

            }

        }

    }

    override fun onDetachedFromEngine(
        binding: FlutterPlugin.FlutterPluginBinding
    ) {

        channel.setMethodCallHandler(null)

    }

}