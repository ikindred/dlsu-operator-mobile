package com.example.operator_mobile_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.example.operator_mobile_app.mifare.MifareReaderPlugin

class MainActivity : FlutterActivity() {

    private var mifareReaderPlugin: MifareReaderPlugin? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        mifareReaderPlugin = MifareReaderPlugin()
        flutterEngine.plugins.add(mifareReaderPlugin!!)
    }
}
