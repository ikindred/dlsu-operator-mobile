import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_ios.dart' show MiFareIos;

/// Result of reading an NFC/MIFARE tag (UID as hex string).
class NfcCardResult {
  const NfcCardResult({required this.uid, required this.timestamp});

  final String uid;
  final int timestamp;
}

/// Uses the device's built-in NFC (no SDK).
/// Android: foreground dispatch (reliable on C66 and most devices).
/// iOS: nfc_manager.
class NfcService {
  NfcService()
    : _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 4,
          lineLength: 80,
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
      ),
      _nfcChannel = const MethodChannel(
        'com.example.operator_mobile_app/nfc_foreground',
      ),
      _nfcEventChannel = const EventChannel(
        'com.example.operator_mobile_app/nfc_tag_events',
      );

  final Logger _logger;
  final MethodChannel _nfcChannel;
  final EventChannel _nfcEventChannel;

  /// Check if NFC is available and enabled.
  Future<bool> get isAvailable async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final ok = await _nfcChannel.invokeMethod<bool>('isNfcAvailable');
        return ok ?? false;
      }
      final a = await NfcManager.instance.checkAvailability();
      return a == NfcAvailability.enabled;
    } catch (e) {
      _logger.w('NFC check failed: $e');
      return false;
    }
  }

  static const Duration _sessionTimeout = Duration(seconds: 45);

  /// Wait for one NFC tag. Android: foreground dispatch. iOS: nfc_manager.
  Future<NfcCardResult?> readTag() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _readTagAndroid();
    }
    return _readTagIos();
  }

  /// Android: enable foreground dispatch and listen for tag intent.
  Future<NfcCardResult?> _readTagAndroid() async {
    try {
      final available = await isAvailable;
      if (!available) {
        _logger.w('NFC is not available or disabled');
        return null;
      }

      final completer = Completer<NfcCardResult?>();
      void complete(NfcCardResult? r) {
        if (!completer.isCompleted) completer.complete(r);
      }

      StreamSubscription? sub;
      sub = _nfcEventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (completer.isCompleted) return;
          final uid = event is String ? event : event?.toString();
          if (uid != null && uid.isNotEmpty) {
            _logger.i('NFC tag read (foreground): $uid');
            sub?.cancel();
            _nfcChannel.invokeMethod('disableNfcForeground');
            complete(
              NfcCardResult(
                uid: uid.toUpperCase(),
                timestamp: DateTime.now().millisecondsSinceEpoch,
              ),
            );
          }
        },
        onError: (e) {
          _logger.w('NFC event error: $e');
          if (!completer.isCompleted) complete(null);
        },
        onDone: () {
          if (!completer.isCompleted) complete(null);
        },
        cancelOnError: true,
      );

      Future.delayed(_sessionTimeout, () {
        if (!completer.isCompleted) {
          _logger.d('NFC session timeout');
          sub?.cancel();
          _nfcChannel.invokeMethod('disableNfcForeground');
          complete(null);
        }
      });

      await _nfcChannel.invokeMethod('enableNfcForeground');
      return completer.future;
    } catch (e, st) {
      _logger.w('NFC read error: $e');
      _logger.d(st.toString());
      return null;
    }
  }

  /// iOS: nfc_manager session.
  Future<NfcCardResult?> _readTagIos() async {
    try {
      final available = await isAvailable;
      if (!available) return null;

      final completer = Completer<NfcCardResult?>();
      void complete(NfcCardResult? r) {
        if (!completer.isCompleted) completer.complete(r);
      }

      Future.delayed(_sessionTimeout, () {
        if (!completer.isCompleted) {
          NfcManager.instance.stopSession();
          complete(null);
        }
      });

      NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443},
        onDiscovered: (NfcTag tag) async {
          final id = MiFareIos.from(tag)?.identifier;
          if (id != null && id.isNotEmpty) {
            final res = NfcCardResult(
              uid: _bytesToHex(id),
              timestamp: DateTime.now().millisecondsSinceEpoch,
            );
            await NfcManager.instance.stopSession();
            complete(res);
          }
        },
      );

      return completer.future;
    } catch (e) {
      _logger.w('NFC read error: $e');
      return null;
    }
  }

  static String _bytesToHex(Uint8List bytes) {
    return bytes
        .map((b) => (b & 0xff).toRadixString(16).padLeft(2, '0').toUpperCase())
        .join();
  }

  /// Cancel current scan (disable foreground dispatch on Android, stop session on iOS).
  Future<void> stopSession() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _nfcChannel.invokeMethod('disableNfcForeground');
      } else {
        await NfcManager.instance.stopSession();
      }
    } catch (e) {
      _logger.d('stopSession: $e');
    }
  }
}
