package com.example.myquran

import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app/file_provider")
            .setMethodCallHandler { call, result ->
                if (call.method == "getUriForFile") {
                    val path = call.argument<String>("path")
                    if (path == null) {
                        result.error("BAD_ARGUMENT", "path is required", null)
                        return@setMethodCallHandler
                    }
                    val uri = FileProvider.getUriForFile(
                        this,
                        "$packageName.fileprovider",
                        File(path)
                    )
                    result.success(uri.toString())
                } else {
                    result.notImplemented()
                }
            }
    }
}
