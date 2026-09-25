package com.example.testing_component

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        /**
         * Channel name must match the one declared in Dart.
         */
        private const val CHANNEL = "external_app_launcher"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openPaymentApp" -> {
                        val url = call.argument<String>("url")
                        if (url.isNullOrBlank()) {
                            result.error("INVALID_URL", "URL must not be null or empty", null)
                            return@setMethodCallHandler
                        }
                        openPaymentApp(url, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Opens the payment URL/app as a completely separate Android task so that:
     *
     *  • App A (this app) stays fully alive — it is NOT finished or removed.
     *  • App B (payment app) appears as its own entry in Android Recent Apps.
     *  • The user can freely switch between App A and App B via the task switcher.
     *
     * ## Why these specific flags?
     *
     * FLAG_ACTIVITY_NEW_TASK
     *   Required when starting an Activity from a non-Activity context, but also
     *   ensures the target Activity is placed into its own task rather than being
     *   stacked on top of ours.
     *
     * FLAG_ACTIVITY_MULTIPLE_TASK
     *   Without this flag, Android re-uses an existing task that already has the
     *   target app running (bringing it to the front instead of creating a new task).
     *   With this flag, Android always creates a BRAND-NEW task for the target, which
     *   guarantees both tasks coexist independently in Recents.
     *
     * ## Important caveat about the target app
     *   If the payment app's Activity is declared with launchMode="singleInstance"
     *   or launchMode="singleTask" AND it does NOT respect FLAG_ACTIVITY_MULTIPLE_TASK,
     *   the OS may still route to its existing task. In practice, banking apps (ABA,
     *   Khemra, etc.) do NOT use singleInstance, so this flag combination works.
     *
     * ## What we deliberately do NOT do
     *   • finish()              — would kill App A.
     *   • finishAndRemoveTask() — would remove App A from Recents.
     *   • moveTaskToBack()      — unnecessary; the OS moves App A back automatically
     *                             when App B's task comes to the foreground.
     */
    private fun openPaymentApp(url: String, result: MethodChannel.Result) {
        try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                addFlags(
                    // Place App B in its own independent task.
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                    // Force a new task even if App B is already running,
                    // so both App A and App B appear separately in Recents.
                    Intent.FLAG_ACTIVITY_MULTIPLE_TASK
                )
            }

            // Verify something on the device can actually handle this URL
            // before calling startActivity (avoids ActivityNotFoundException crash).
            val canHandle = intent.resolveActivity(packageManager) != null
            if (!canHandle) {
                // Nothing can handle the URL natively. Let Flutter decide what to do.
                result.error(
                    "NO_HANDLER",
                    "No app found that can handle URL: $url",
                    null
                )
                return
            }

            startActivity(intent)

            // Return success immediately — we do not wait for the payment app to finish.
            // The callback/deep-link (fakebank://) flow handles the return journey.
            result.success(true)

        } catch (e: Exception) {
            result.error("LAUNCH_FAILED", e.localizedMessage, null)
        }
    }
}
