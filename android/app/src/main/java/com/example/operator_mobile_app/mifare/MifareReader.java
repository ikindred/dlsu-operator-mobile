/**
 * Native implementation of MIFARE (ISO 14443A) card reading using Chainway C66 DeviceAPI.
 * Uses RFIDWithISO14443A from the SDK in android/app/libs for HF/NFC card scanning.
 */
package com.example.operator_mobile_app.mifare;

import android.content.Context;
import android.media.AudioManager;
import android.media.ToneGenerator;
import android.util.Log;

import com.rscja.deviceapi.RFIDWithISO14443A;
import com.rscja.deviceapi.exception.ConfigurationException;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.BinaryMessenger;

/**
 * Handles MIFARE card reader operations via MethodChannel.
 */
public class MifareReader implements MethodCallHandler {
    private static final String TAG = "MifareReader";
    private static final String CHANNEL = "com.example.operator_mobile_app/mifare_reader";

    private final Context context;
    private final MethodChannel channel;
    private RFIDWithISO14443A rfid14443;
    private boolean isInitialized = false;
    private ToneGenerator toneGenerator;

    public MifareReader(Context context, BinaryMessenger messenger) {
        this.context = context;
        this.channel = new MethodChannel(messenger, CHANNEL);
        this.channel.setMethodCallHandler(this);
        try {
            toneGenerator = new ToneGenerator(AudioManager.STREAM_SYSTEM, 100);
        } catch (Exception e) {
            Log.e(TAG, "ToneGenerator init failed: " + e.getMessage());
        }
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        Log.d(TAG, "Method call: " + call.method);
        switch (call.method) {
            case "initialize":
                initialize(result);
                break;
            case "readCard":
                readCard(result);
                break;
            case "disposeReader":
                dispose(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * Initialize the MIFARE (ISO 14443A) reader hardware.
     */
    private void initialize(Result result) {
        try {
            if (isInitialized) {
                result.success(true);
                return;
            }
            rfid14443 = RFIDWithISO14443A.getInstance();
            if (rfid14443 == null) {
                Log.e(TAG, "RFIDWithISO14443A getInstance() returned null");
                result.error("INIT_ERROR", "Failed to get ISO14443A reader instance", null);
                return;
            }
            if (rfid14443.init()) {
                isInitialized = true;
                Log.d(TAG, "MIFARE reader initialized successfully");
                result.success(true);
            } else {
                Log.e(TAG, "RFIDWithISO14443A init() failed");
                result.error("INIT_ERROR", "Failed to initialize MIFARE reader", null);
            }
        } catch (ConfigurationException e) {
            Log.e(TAG, "ConfigurationException: " + e.getMessage());
            result.error("INIT_ERROR", e.getMessage(), null);
        } catch (Exception e) {
            Log.e(TAG, "Initialize error: " + e.getMessage());
            result.error("INIT_ERROR", e.getMessage(), null);
        }
    }

    /**
     * Perform a single MIFARE card read (request card and return UID).
     * Runs on a background thread to avoid blocking the UI.
     */
    private void readCard(Result result) {
        if (!isInitialized || rfid14443 == null) {
            result.error("NOT_INITIALIZED", "MIFARE reader not initialized", null);
            return;
        }
        new Thread(() -> {
            try {
                byte[] uid = null;
                // SDK: request() may return byte[] (UID) or boolean; getUID() may exist for post-request
                try {
                    java.lang.reflect.Method requestMethod = rfid14443.getClass().getMethod("request");
                    Object ret = requestMethod.invoke(rfid14443);
                    if (ret instanceof byte[]) {
                        uid = (byte[]) ret;
                    } else if (ret instanceof Boolean && (Boolean) ret) {
                        try {
                            java.lang.reflect.Method getUid = rfid14443.getClass().getMethod("getUID");
                            Object u = getUid.invoke(rfid14443);
                            if (u instanceof byte[]) uid = (byte[]) u;
                        } catch (Exception e) {
                            Log.w(TAG, "getUID after request: " + e.getMessage());
                        }
                    }
                } catch (Exception e) {
                    Log.e(TAG, "request/getUID reflection: " + e.getMessage());
                }
                if (uid == null || uid.length == 0) {
                    runOnMain(() -> result.error("READ_ERROR", "No card detected or reader busy", null));
                    return;
                }
                final String uidHex = bytesToHex(uid);
                playBeep();
                Map<String, Object> data = new HashMap<>();
                data.put("uid", uidHex);
                data.put("timestamp", System.currentTimeMillis());
                runOnMain(() -> result.success(data));
            } catch (Exception e) {
                Log.e(TAG, "readCard error: " + e.getMessage());
                runOnMain(() -> result.error("READ_ERROR", e.getMessage(), null));
            }
        }).start();
    }

    private void runOnMain(Runnable r) {
        new android.os.Handler(android.os.Looper.getMainLooper()).post(r);
    }

    private static String bytesToHex(byte[] bytes) {
        if (bytes == null) return "";
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            sb.append(String.format("%02X", b & 0xff));
        }
        return sb.toString();
    }

    private void playBeep() {
        try {
            if (toneGenerator != null)
                toneGenerator.startTone(ToneGenerator.TONE_PROP_BEEP, 100);
        } catch (Exception e) {
            Log.e(TAG, "Beep failed: " + e.getMessage());
        }
    }

    private void dispose(Result result) {
        try {
            if (toneGenerator != null) {
                toneGenerator.release();
                toneGenerator = null;
            }
            if (rfid14443 != null) {
                try {
                    rfid14443.free();
                } catch (Throwable t) {
                    Log.w(TAG, "rfid14443.free(): " + t.getMessage());
                }
                rfid14443 = null;
            }
            isInitialized = false;
            Log.d(TAG, "MIFARE reader disposed");
            result.success(true);
        } catch (Exception e) {
            Log.e(TAG, "dispose error: " + e.getMessage());
            result.error("DISPOSE_ERROR", e.getMessage(), null);
        }
    }

    /**
     * Release resources. Call when plugin is detached.
     */
    public void dispose() {
        try {
            if (toneGenerator != null) {
                toneGenerator.release();
                toneGenerator = null;
            }
            if (rfid14443 != null) {
                try {
                    rfid14443.free();
                } catch (Throwable t) {
                    Log.w(TAG, "rfid14443.free(): " + t.getMessage());
                }
                rfid14443 = null;
            }
            isInitialized = false;
            Log.d(TAG, "MIFARE reader disposed");
        } catch (Exception e) {
            Log.e(TAG, "dispose error: " + e.getMessage());
        }
    }
}
