package com.example.vpn_front

import android.content.Intent
import android.net.VpnService
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.vpn_front/vpn"
    private val VPN_REQUEST_CODE = 0x0F
    private var pendingVpnPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestVpnPermission" -> {
                    requestVpnPermission(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun requestVpnPermission(result: MethodChannel.Result) {
        val intent = VpnService.prepare(this)
        if (intent != null) {
            // Разрешение не предоставлено, нужно запросить
            Log.d("MainActivity", "Requesting VPN permission from user")
            pendingVpnPermissionResult = result
            startActivityForResult(intent, VPN_REQUEST_CODE)
            // Не вызываем result.success() здесь, ждем результата в onActivityResult
        } else {
            // Разрешение уже предоставлено
            Log.d("MainActivity", "VPN permission already granted")
            result.success(true)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == VPN_REQUEST_CODE) {
            val granted = resultCode == RESULT_OK
            if (granted) {
                Log.d("MainActivity", "VPN permission granted by user")
            } else {
                Log.d("MainActivity", "VPN permission denied by user")
            }
            
            // Отправляем результат в Flutter
            pendingVpnPermissionResult?.success(granted)
            pendingVpnPermissionResult = null
        }
    }
}
