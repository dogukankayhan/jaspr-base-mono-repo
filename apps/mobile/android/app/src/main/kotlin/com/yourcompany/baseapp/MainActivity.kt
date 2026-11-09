package com.yourcompany.baseapp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val ENVIRONMENT_CHANNEL = "com.yourcompany.baseapp/environment"
    private val SECURITY_CHANNEL = "com.yourcompany.baseapp/security"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ENVIRONMENT_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getEnvironmentConfig") {
                    val appName = getString(R.string.app_name)
                    val baseUrl = getString(R.string.base_url)
                    val googleServerClientId = getString(R.string.google_server_client_id)
                    result.success(
                        mapOf(
                            "appName" to appName,
                            "baseUrl" to baseUrl,
                            "googleServerClientId" to googleServerClientId
                        )
                    )
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURITY_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "isJailbroken") {
                    val manager = JailbreakDetectionManager(this)
                    result.success(manager.isRooted())
                } else {
                    result.notImplemented()
                }
            }
    }
}
