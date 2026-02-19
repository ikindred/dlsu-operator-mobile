package com.example.operator_mobile_app

import android.content.Intent
import android.content.IntentFilter
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.os.Build
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.example.operator_mobile_app.mifare.MifareReaderPlugin

class MainActivity : FlutterActivity() {

    private var mifareReaderPlugin: MifareReaderPlugin? = null

    companion object {
        private const val TAG = "MainActivity"
        private const val NFC_CHANNEL = "com.example.operator_mobile_app/nfc_foreground"
        private const val NFC_EVENT_CHANNEL = "com.example.operator_mobile_app/nfc_tag_events"
    }

    private var nfcAdapter: NfcAdapter? = null
    private var nfcEventSink: EventChannel.EventSink? = null
    private var foregroundDispatchEnabled = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        mifareReaderPlugin = MifareReaderPlugin()
        flutterEngine.plugins.add(mifareReaderPlugin!!)

        nfcAdapter = NfcAdapter.getDefaultAdapter(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NFC_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableNfcForeground" -> {
                    enableNfcForegroundDispatch()
                    result.success(true)
                }
                "disableNfcForeground" -> {
                    disableNfcForegroundDispatch()
                    result.success(true)
                }
                "isNfcAvailable" -> {
                    result.success(nfcAdapter != null && nfcAdapter?.isEnabled == true)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, NFC_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    nfcEventSink = events
                    Log.d(TAG, "NFC event channel: Flutter is listening")
                }
                override fun onCancel(arguments: Any?) {
                    nfcEventSink = null
                    Log.d(TAG, "NFC event channel: Flutter cancelled")
                }
            }
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleNfcIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleNfcIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        if (foregroundDispatchEnabled) {
            enableNfcForegroundDispatch()
        }
    }

    override fun onPause() {
        super.onPause()
        // Disable while paused (required by Android); we re-enable in onResume if needed
        nfcAdapter?.disableForegroundDispatch(this)
    }

    private fun handleNfcIntent(intent: Intent?) {
        if (intent == null) return
        val action = intent.action
        if (NfcAdapter.ACTION_TAG_DISCOVERED == action ||
            NfcAdapter.ACTION_TECH_DISCOVERED == action ||
            NfcAdapter.ACTION_NDEF_DISCOVERED == action) {
            val tag: Tag? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                intent.getParcelableExtra(NfcAdapter.EXTRA_TAG, Tag::class.java)
            } else {
                @Suppress("DEPRECATION")
                intent.getParcelableExtra(NfcAdapter.EXTRA_TAG)
            }
            tag?.let { sendTagIdToFlutter(it) }
        }
    }

    private fun sendTagIdToFlutter(tag: Tag) {
        val id = tag.id
        val hex = id.joinToString("") { b -> "%02X".format((b.toInt() and 0xff)) }
        Log.i(TAG, "NFC tag discovered, UID: $hex")
        runOnUiThread {
            try {
                nfcEventSink?.success(hex)
            } catch (e: Exception) {
                Log.e(TAG, "Error sending tag to Flutter: ${e.message}")
            }
        }
    }

    private fun enableNfcForegroundDispatch() {
        val adapter = nfcAdapter ?: return
        if (!adapter.isEnabled) return
        try {
            val intent = Intent(this, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            }
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                android.app.PendingIntent.FLAG_MUTABLE
            } else {
                0
            }
            val pendingIntent = android.app.PendingIntent.getActivity(this, 0, intent, flags)
            val filters = arrayOf(IntentFilter(NfcAdapter.ACTION_TAG_DISCOVERED))
            adapter.enableForegroundDispatch(this, pendingIntent, filters, null)
            foregroundDispatchEnabled = true
            Log.d(TAG, "NFC foreground dispatch enabled")
        } catch (e: Exception) {
            Log.e(TAG, "enableForegroundDispatch failed: ${e.message}")
        }
    }

    private fun disableNfcForegroundDispatch() {
        nfcAdapter?.disableForegroundDispatch(this)
        foregroundDispatchEnabled = false
        Log.d(TAG, "NFC foreground dispatch disabled (by Flutter)")
    }
}
