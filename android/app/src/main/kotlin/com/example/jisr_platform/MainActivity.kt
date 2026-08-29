package com.example.jisr_platform

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.view.View
import android.view.WindowInsets
import android.view.WindowInsetsController
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val ASSESSMENT_LOCK_CHANNEL = "jisr_platform/assessment_lock"
    }

    private var assessmentLockRequested = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ASSESSMENT_LOCK_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLockTaskMode" -> startAssessmentLock(result)
                "stopLockTaskMode" -> stopAssessmentLock(result)
                "refreshLockTaskMode" -> refreshAssessmentLock(result)
                "isInLockTaskMode" -> result.success(lockTaskModeState() != ActivityManager.LOCK_TASK_MODE_NONE)
                else -> result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        if (assessmentLockRequested) {
            hideSystemBars()
        }
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus && assessmentLockRequested) {
            hideSystemBars()
        }
    }

    private fun startAssessmentLock(result: MethodChannel.Result) {
        assessmentLockRequested = true
        hideSystemBars()

        try {
            if (lockTaskModeState() == ActivityManager.LOCK_TASK_MODE_NONE) {
                // On a normal phone this requests Android screen pinning. On a
                // managed/allow-listed device it enters full kiosk lock-task
                // mode without changing any Flutter assessment logic.
                startLockTask()
            }
            result.success(lockStatePayload())
        } catch (error: Exception) {
            assessmentLockRequested = false
            showSystemBars()
            result.error("ASSESSMENT_LOCK_START_FAILED", error.message, null)
        }
    }

    private fun stopAssessmentLock(result: MethodChannel.Result) {
        assessmentLockRequested = false

        try {
            if (lockTaskModeState() != ActivityManager.LOCK_TASK_MODE_NONE) {
                stopLockTask()
            }
            showSystemBars()
            result.success(true)
        } catch (error: Exception) {
            showSystemBars()
            result.error("ASSESSMENT_LOCK_STOP_FAILED", error.message, null)
        }
    }

    private fun refreshAssessmentLock(result: MethodChannel.Result) {
        if (assessmentLockRequested) {
            hideSystemBars()
        }
        result.success(lockStatePayload())
    }

    private fun lockStatePayload(): Map<String, Any> {
        val state = lockTaskModeState()
        return mapOf(
            "active" to (state != ActivityManager.LOCK_TASK_MODE_NONE),
            "mode" to when (state) {
                ActivityManager.LOCK_TASK_MODE_LOCKED -> "locked"
                ActivityManager.LOCK_TASK_MODE_PINNED -> "pinned"
                else -> "requested"
            }
        )
    }

    @Suppress("DEPRECATION")
    private fun lockTaskModeState(): Int {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            activityManager.lockTaskModeState
        } else if (activityManager.isInLockTaskMode) {
            ActivityManager.LOCK_TASK_MODE_LOCKED
        } else {
            ActivityManager.LOCK_TASK_MODE_NONE
        }
    }

    @Suppress("DEPRECATION")
    private fun hideSystemBars() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.insetsController?.let { controller ->
                controller.hide(WindowInsets.Type.statusBars() or WindowInsets.Type.navigationBars())
                controller.systemBarsBehavior =
                    WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        } else {
            window.decorView.systemUiVisibility =
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or
                    View.SYSTEM_UI_FLAG_FULLSCREEN or
                    View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
                    View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
                    View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
                    View.SYSTEM_UI_FLAG_LAYOUT_STABLE
        }
    }

    @Suppress("DEPRECATION")
    private fun showSystemBars() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.insetsController?.show(
                WindowInsets.Type.statusBars() or WindowInsets.Type.navigationBars()
            )
        } else {
            window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_VISIBLE
        }
    }
}
