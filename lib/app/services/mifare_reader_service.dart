import 'dart:async';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

/// Result of a single MIFARE card read from the C66 DeviceAPI (ISO 14443A).
class MifareCardResult {
  const MifareCardResult({
    required this.uid,
    required this.timestamp,
  });

  final String uid;
  final int timestamp;

  factory MifareCardResult.fromJson(Map<dynamic, dynamic> json) {
    return MifareCardResult(
      uid: json['uid'] as String? ?? '',
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Service to scan MIFARE cards via the Chainway C66 SDK (android/app/libs).
/// Uses the same DeviceAPI AAR as the UHF reader; this path uses RFIDWithISO14443A for HF/MIFARE.
class MifareReaderService {
  MifareReaderService() : _channel = const MethodChannel('com.example.operator_mobile_app/mifare_reader');

  final MethodChannel _channel;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// Initialize the MIFARE reader hardware. Call once before [readCard].
  Future<bool> initialize() async {
    _logger.d('🔧 Initializing MIFARE reader...');
    try {
      final result = await _channel.invokeMethod<bool>('initialize');
      final success = result ?? false;
      if (success) {
        _logger.i('✅ MIFARE reader initialized successfully');
      } else {
        _logger.w('⚠️ MIFARE reader initialization returned false');
      }
      return success;
    } on PlatformException catch (e, stackTrace) {
      _logger.e('❌ Failed to initialize MIFARE reader', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Perform a single MIFARE card read. Hold the card near the device.
  /// Returns [MifareCardResult] with UID (hex string) and timestamp, or null on error/no card.
  Future<MifareCardResult?> readCard() async {
    _logger.d('📖 Reading card...');
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('readCard');
      if (result == null) {
        _logger.d('📭 No card detected');
        return null;
      }
      final cardResult = MifareCardResult.fromJson(result);
      _logger.i('✅ Card read successfully. UID: ${cardResult.uid}');
      return cardResult;
    } on PlatformException catch (e, stackTrace) {
      _logger.w('⚠️ Card read error', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Release the reader. Call when done (e.g. on logout or app pause).
  Future<void> disposeReader() async {
    _logger.d('🗑️ Disposing MIFARE reader...');
    try {
      await _channel.invokeMethod('disposeReader');
      _logger.i('✅ MIFARE reader disposed');
    } on PlatformException catch (e, stackTrace) {
      _logger.e('❌ Error disposing MIFARE reader', error: e, stackTrace: stackTrace);
    }
  }
}
