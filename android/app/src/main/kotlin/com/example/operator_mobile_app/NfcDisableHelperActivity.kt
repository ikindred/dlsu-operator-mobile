package com.example.operator_mobile_app

import android.app.Activity
import android.os.Bundle
import android.util.Log

/**
 * Transparent activity that finishes immediately. Started when we need to disable NFC
 * foreground dispatch: Android only allows disableForegroundDispatch() in onPause(), so
 * we briefly start this activity so MainActivity goes to onPause and can disable NFC.
 */
class NfcDisableHelperActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("MainActivity", "[NFC] NfcDisableHelperActivity onCreate — finishing (MainActivity will onPause and disable NFC)")
        finish()
    }
}
