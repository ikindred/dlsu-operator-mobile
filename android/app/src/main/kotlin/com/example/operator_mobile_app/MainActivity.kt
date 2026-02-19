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
    /// Only deliver one tag per scan; ignore further taps until Flutter starts a new scan.
    private var nfcTagAlreadySentThisSession = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        mifareReaderPlugin = MifareReaderPlugin()
        flutterEngine.plugins.add(mifareReaderPlugin!!)

        nfcAdapter = NfcAdapter.getDefaultAdapter(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NFC_CHANNEL).setMethodCallHandler { call, result ->
            Log.d(TAG, "[NFC] MethodChannel call: ${call.method}")
            when (call.method) {
                "enableNfcForeground" -> {
                    Log.d(TAG, "[NFC] enableNfcForeground requested from Flutter")
                    enableNfcForegroundDispatch()
                    result.success(true)
                }
                "disableNfcForeground" -> {
                    Log.d(TAG, "[NFC] disableNfcForeground requested from Flutter")
                    disableNfcForegroundDispatch()
                    result.success(true)
                }
                "isNfcAvailable" -> {
                    val available = nfcAdapter != null && nfcAdapter?.isEnabled == true
                    Log.d(TAG, "[NFC] isNfcAvailable => $available")
                    result.success(available)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, NFC_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    nfcEventSink = events
                    Log.d(TAG, "[NFC] EventChannel onListen — Flutter is listening for tag events")
                }
                override fun onCancel(arguments: Any?) {
                    nfcEventSink = null
                    Log.d(TAG, "[NFC] EventChannel onCancel — Flutter cancelled listener")
                }
            }
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "[NFC] onCreate — handling intent if NFC")
        handleNfcIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        Log.d(TAG, "[NFC] onNewIntent — action=${intent.action}")
        handleNfcIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        Log.d(TAG, "[NFC] onResume — foregroundDispatchEnabled=$foregroundDispatchEnabled")
        if (foregroundDispatchEnabled) {
            Log.d(TAG, "[NFC] onResume — re-enabling foreground dispatch")
            enableNfcForegroundDispatch()
        }
    }

    override fun onPause() {
        super.onPause()
        Log.d(TAG, "[NFC] onPause — disabling foreground dispatch, clearing flag")
        nfcAdapter?.disableForegroundDispatch(this)
        foregroundDispatchEnabled = false
    }

    private fun handleNfcIntent(intent: Intent?) {
        if (intent == null) return
        val action = intent.action ?: ""
        if (action != NfcAdapter.ACTION_TAG_DISCOVERED &&
            action != NfcAdapter.ACTION_TECH_DISCOVERED &&
            action != NfcAdapter.ACTION_NDEF_DISCOVERED) return
        Log.d(TAG, "[NFC] handleNfcIntent — action=$action")
        if (nfcTagAlreadySentThisSession) {
            Log.d(TAG, "[NFC] handleNfcIntent — ignored (already sent a tag this session)")
            return
        }
        val inScanningMode = foregroundDispatchEnabled || nfcEventSink != null
        Log.d(TAG, "[NFC] handleNfcIntent — inScanningMode=$inScanningMode (foreground=$foregroundDispatchEnabled sink=${nfcEventSink != null})")
        if (!inScanningMode) {
            Log.d(TAG, "[NFC] handleNfcIntent — ignored (not in scanning mode)")
            return
        }
        val tag: Tag? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(NfcAdapter.EXTRA_TAG, Tag::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(NfcAdapter.EXTRA_TAG)
        }
        if (tag != null) {
            Log.d(TAG, "[NFC] handleNfcIntent — accepting tag, sending to Flutter")
            sendTagIdToFlutter(tag)
        } else {
            Log.w(TAG, "[NFC] handleNfcIntent — no EXTRA_TAG in intent")
        }
    }

    private fun sendTagIdToFlutter(tag: Tag) {
        val id = tag.id
        val hex = id.joinToString("") { b -> "%02X".format((b.toInt() and 0xff)) }
        Log.i(TAG, "[NFC] sendTagIdToFlutter — UID=$hex")
        runOnUiThread {
            try {
                if (nfcEventSink != null) {
                    Log.d(TAG, "[NFC] sendTagIdToFlutter — sink set, sending UID then disabling")
                    nfcEventSink?.success(hex)
                    nfcTagAlreadySentThisSession = true
                    disableNfcForegroundDispatch()
                } else {
                    Log.d(TAG, "[NFC] sendTagIdToFlutter — sink null, scheduling retry in 250ms")
                    android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                        try {
                            nfcEventSink?.success(hex)
                            if (nfcEventSink != null) {
                                Log.d(TAG, "[NFC] sendTagIdToFlutter — retry: UID sent, disabling")
                                nfcTagAlreadySentThisSession = true
                                disableNfcForegroundDispatch()
                            }
                        } catch (e: Exception) {
                            Log.e(TAG, "[NFC] sendTagIdToFlutter retry error: ${e.message}")
                        }
                    }, 250)
                }
            } catch (e: Exception) {
                Log.e(TAG, "[NFC] sendTagIdToFlutter error: ${e.message}")
            }
        }
    }

    private fun enableNfcForegroundDispatch() {
        val adapter = nfcAdapter
        if (adapter == null) {
            Log.w(TAG, "[NFC] enableNfcForegroundDispatch — nfcAdapter is null")
            return
        }
        if (!adapter.isEnabled) {
            Log.w(TAG, "[NFC] enableNfcForegroundDispatch — NFC is disabled in settings")
            return
        }
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
            nfcTagAlreadySentThisSession = false
            Log.d(TAG, "[NFC] enableNfcForegroundDispatch — ok, reader ON")
        } catch (e: Exception) {
            Log.e(TAG, "[NFC] enableNfcForegroundDispatch failed: ${e.message}")
        }
    }

    private fun disableNfcForegroundDispatch() {
        Log.d(TAG, "[NFC] disableNfcForegroundDispatch — setting flag=false, starting NfcDisableHelperActivity (trigger onPause)")
        foregroundDispatchEnabled = false
        try {
            startActivity(Intent(this, NfcDisableHelperActivity::class.java))
        } catch (e: Exception) {
            Log.e(TAG, "[NFC] disableNfcForegroundDispatch — failed to start helper: ${e.message}")
        }
    }
}
