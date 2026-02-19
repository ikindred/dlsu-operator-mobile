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

  /// Active tag-read subscription; cancelled in stopSession() so native sink clears when leaving Scanner.
  StreamSubscription<dynamic>? _tagSubscription;
  void Function()? _cancelTagRead;

  /// Check if NFC is available and enabled.
  Future<bool> get isAvailable async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final ok = await _nfcChannel.invokeMethod<bool>('isNfcAvailable');
        _logger.d('[NFC] isAvailable (Android) => $ok');
        return ok ?? false;
      }
      final a = await NfcManager.instance.checkAvailability();
      _logger.d('[NFC] isAvailable (iOS) => $a');
      return a == NfcAvailability.enabled;
    } catch (e) {
      _logger.w('[NFC] isAvailable failed: $e');
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
      _logger.d('[NFC] _readTagAndroid start');
      final available = await isAvailable;
      if (!available) {
        _logger.w('[NFC] _readTagAndroid aborted — NFC not available or disabled');
        return null;
      }

      final completer = Completer<NfcCardResult?>();
      void complete(NfcCardResult? r) {
        if (!completer.isCompleted) completer.complete(r);
        _tagSubscription = null;
        _cancelTagRead = null;
      }

      _logger.d('[NFC] attaching EventChannel listener (tag_events)');
      StreamSubscription<dynamic>? sub;
      sub = _nfcEventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (completer.isCompleted) return;
          final uid = event is String ? event : event?.toString();
          if (uid != null && uid.isNotEmpty) {
            _logger.i('[NFC] tag received on stream => uid=$uid, cancelling subscription, calling disableNfcForeground');
            sub?.cancel();
            _nfcChannel.invokeMethod('disableNfcForeground');
            complete(
              NfcCardResult(
                uid: uid.trim().toUpperCase(),
                timestamp: DateTime.now().millisecondsSinceEpoch,
              ),
            );
          }
        },
        onError: (e) {
          _logger.w('[NFC] tag stream onError: $e');
          if (!completer.isCompleted) complete(null);
        },
        onDone: () {
          _logger.d('[NFC] tag stream onDone');
          if (!completer.isCompleted) complete(null);
        },
        cancelOnError: true,
      );

      _tagSubscription = sub;
      _cancelTagRead = () {
        if (!completer.isCompleted) {
          _logger.d('[NFC] _cancelTagRead: cancelling sub + disableNfcForeground');
          sub?.cancel();
          _nfcChannel.invokeMethod('disableNfcForeground');
          complete(null);
        }
      };

      Future.delayed(_sessionTimeout, () {
        if (!completer.isCompleted) {
          _logger.d('[NFC] session timeout (${_sessionTimeout.inSeconds}s), cancelling');
          _cancelTagRead?.call();
        }
      });

      _logger.d('[NFC] delay 150ms then enableNfcForeground');
      await Future.delayed(const Duration(milliseconds: 150));
      await _nfcChannel.invokeMethod('enableNfcForeground');
      _logger.d('[NFC] enableNfcForeground returned, waiting for tag or timeout');
      final out = await completer.future;
      _logger.d('[NFC] readTag returning: ${out != null ? "uid=${out.uid}" : "null"}');
      return out;
    } catch (e, st) {
      _logger.w('[NFC] _readTagAndroid error: $e');
      _logger.d(st.toString());
      _tagSubscription = null;
      _cancelTagRead = null;
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
  /// On Android, cancels the tag listener so native nfcEventSink is cleared (no tag handling on Home).
  Future<void> stopSession() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        _logger.d('[NFC] stopSession: cancel subscription + disableNfcForeground');
        _tagSubscription?.cancel();
        _tagSubscription = null;
        _cancelTagRead?.call();
        _cancelTagRead = null;
        await _nfcChannel.invokeMethod('disableNfcForeground');
        _logger.d('[NFC] stopSession done');
      } else {
        _logger.d('[NFC] stopSession (iOS)');
        await NfcManager.instance.stopSession();
      }
    } catch (e) {
      _logger.d('[NFC] stopSession error: $e');
    }
  }
}
