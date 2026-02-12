package com.example.operator_mobile_app.mifare;

import android.content.Context;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

/**
 * Flutter plugin for MIFARE (ISO 14443A) card reading on Chainway C66.
 */
public class MifareReaderPlugin implements FlutterPlugin {
    private static final String CHANNEL = "com.example.operator_mobile_app/mifare_reader";
    private MifareReader mifareReader;

    @Override
    public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
        Context context = binding.getApplicationContext();
        BinaryMessenger messenger = binding.getBinaryMessenger();
        mifareReader = new MifareReader(context, messenger);
    }

    @Override
    public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding binding) {
        if (mifareReader != null) {
            mifareReader.dispose();
            mifareReader = null;
        }
    }

    public MifareReader getMifareReader() {
        return mifareReader;
    }
}
