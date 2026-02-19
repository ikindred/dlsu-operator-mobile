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
                logPublicMethods(rfid14443);
                tryCallAfterInit("open");
                tryCallAfterInit("powerOn");
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

    /** Max time to wait for a card tap (milliseconds). */
    private static final int READ_POLL_TIMEOUT_MS = 8000;
    /** Interval between request() calls while waiting for card (milliseconds). */
    private static final int READ_POLL_INTERVAL_MS = 100;
    /** Method names to try for card detection (SDK may use different names). */
    private static final String[] REQUEST_METHOD_NAMES = {"request", "requestA", "findCard", "getCard"};

    private void logPublicMethods(RFIDWithISO14443A reader) {
        try {
            Class<?> c = reader.getClass();
            Log.e(TAG, "Reader class: " + c.getName());
            if (c.getSuperclass() != null) {
                Log.e(TAG, "Reader superclass: " + c.getSuperclass().getName());
            }
            java.lang.reflect.Method[] methods = c.getMethods();
            StringBuilder sb = new StringBuilder("Public methods: ");
            for (java.lang.reflect.Method m : methods) {
                sb.append(m.getName()).append(" ");
            }
            Log.e(TAG, sb.toString());
        } catch (Exception e) {
            Log.w(TAG, "logPublicMethods: " + e.getMessage());
        }
    }

    /** Call parameterless method on reader after init if it exists (e.g. open, powerOn). */
    private void tryCallAfterInit(String methodName) {
        try {
            java.lang.reflect.Method m = rfid14443.getClass().getMethod(methodName);
            Object ret = m.invoke(rfid14443);
            Log.d(TAG, methodName + "() returned: " + (ret != null ? ret : "void"));
        } catch (NoSuchMethodException e) {
            // optional
        } catch (Exception e) {
            Log.w(TAG, methodName + "(): " + e.getMessage());
        }
    }

    /**
     * Perform a MIFARE card read. Polls the reader for up to READ_POLL_TIMEOUT_MS
     * so the user has time to tap the card; returns UID when detected.
     * Polling runs on main thread (some device SDKs require main-thread access).
     */
    private void readCard(Result result) {
        if (!isInitialized || rfid14443 == null) {
            result.error("NOT_INITIALIZED", "MIFARE reader not initialized", null);
            return;
        }
        _loggedRequestReturn = false;
        final android.os.Handler handler = new android.os.Handler(android.os.Looper.getMainLooper());
        final long deadline = System.currentTimeMillis() + READ_POLL_TIMEOUT_MS;
        final int[] pollCount = {0};

        final Runnable pollOnce = new Runnable() {
            @Override
            public void run() {
                if (System.currentTimeMillis() >= deadline) {
                    Log.d(TAG, "Read timeout, no card");
                    result.error("READ_ERROR", "No card detected or reader busy", null);
                    return;
                }
                try {
                    byte[] uid = tryRequestUid();
                    if (uid != null && uid.length > 0) {
                        final String uidHex = bytesToHex(uid);
                        playBeep();
                        Map<String, Object> data = new HashMap<>();
                        data.put("uid", uidHex);
                        data.put("timestamp", System.currentTimeMillis());
                        result.success(data);
                        return;
                    }
                    pollCount[0]++;
                    if (pollCount[0] == 1 || pollCount[0] % 50 == 0) {
                        Log.d(TAG, "Waiting for card... (poll " + pollCount[0] + ")");
                    }
                    handler.postDelayed(this, READ_POLL_INTERVAL_MS);
                } catch (Exception e) {
                    Log.e(TAG, "readCard error: " + e.getMessage());
                    result.error("READ_ERROR", e.getMessage(), null);
                }
            }
        };
        handler.post(pollOnce);
    }

    private boolean _loggedRequestReturn = false;

    /** Try all known request-style methods and getUID(); returns UID bytes or null. */
    private byte[] tryRequestUid() {
        Class<?> clazz = rfid14443.getClass();
        for (String methodName : REQUEST_METHOD_NAMES) {
            try {
                java.lang.reflect.Method m = clazz.getMethod(methodName);
                Object ret = m.invoke(rfid14443);
                if (!_loggedRequestReturn) {
                    logReturn(methodName + "()", ret);
                }
                byte[] u = parseRequestResult(ret);
                if (u != null) {
                    _loggedRequestReturn = false;
                    return u;
                }
            } catch (NoSuchMethodException e) {
                // try next name
            } catch (Exception e) {
                Log.w(TAG, methodName + " failed: " + e.getMessage());
            }
        }
        try {
            java.lang.reflect.Method m = clazz.getMethod("request", int.class);
            Object ret = m.invoke(rfid14443, 500);
            if (!_loggedRequestReturn) {
                logReturn("request(500)", ret);
            }
            byte[] u = parseRequestResult(ret);
            if (u != null) {
                _loggedRequestReturn = false;
                return u;
            }
        } catch (NoSuchMethodException e) {
            // ignore
        } catch (Exception e) {
            Log.w(TAG, "request(int) failed: " + e.getMessage());
        }
        byte[] u = invokeGetUID();
        if (!_loggedRequestReturn) {
            logReturn("getUID()", u);
        }
        _loggedRequestReturn = true;
        return u;
    }

    private void logReturn(String label, Object ret) {
        if (ret == null) {
            Log.e(TAG, "SDK " + label + " returned: null");
        } else if (ret instanceof byte[]) {
            byte[] b = (byte[]) ret;
            Log.e(TAG, "SDK " + label + " returned: byte[" + b.length + "] " + bytesToHex(b));
        } else {
            Log.e(TAG, "SDK " + label + " returned: " + ret.getClass().getSimpleName() + " = " + ret);
        }
    }

    private byte[] parseRequestResult(Object ret) {
        if (ret instanceof byte[]) {
            byte[] u = (byte[]) ret;
            if (u != null && u.length > 0) return u;
        } else if (ret instanceof Boolean && (Boolean) ret) {
            return invokeGetUID();
        } else if (ret instanceof Integer && (Integer) ret != 0) {
            return invokeGetUID();
        }
        return null;
    }

    private byte[] invokeGetUID() {
        try {
            java.lang.reflect.Method getUid = rfid14443.getClass().getMethod("getUID");
            Object u = getUid.invoke(rfid14443);
            if (u instanceof byte[]) {
                byte[] arr = (byte[]) u;
                if (arr != null && arr.length > 0) return arr;
            }
        } catch (Exception e) {
            // ignore
        }
        return null;
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
