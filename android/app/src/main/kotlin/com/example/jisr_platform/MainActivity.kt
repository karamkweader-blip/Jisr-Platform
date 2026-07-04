package com.example.jisr_platform

import io.flutter.embedding.android.FlutterActivity
import android.app.ActivityManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "jisr_platform/assessment_lock"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLockTaskMode" -> {
                    try {
                        startLockTask()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error(
                            "LOCK_TASK_ERROR",
                            e.message ?: "Unable to start lock task mode",
                            null
                        )
                    }
                }

                "stopLockTaskMode" -> {
                    try {
                        stopLockTask()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error(
                            "UNLOCK_TASK_ERROR",
                            e.message ?: "Unable to stop lock task mode",
                            null
                        )
                    }
                }

                "isInLockTaskMode" -> {
                    val activityManager =
                        getSystemService(ACTIVITY_SERVICE) as ActivityManager

                    val locked =
                        activityManager.lockTaskModeState != ActivityManager.LOCK_TASK_MODE_NONE

                    result.success(locked)
                }

                else -> result.notImplemented()
            }
        }
    }
}