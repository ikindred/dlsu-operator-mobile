import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

/// Displays a circular profile image from [profile] when it contains base64 image data.
/// If [profile] is null, empty, or not valid base64 image data, shows a placeholder
/// (icon or initials from [fallbackId]).
///
/// The [profile] column may be base64-encoded image bytes. If your backend uses base62
/// encoding, decode it to bytes (or to a base64 string) before passing here.
class ProfileImageFromData extends StatelessWidget {
  const ProfileImageFromData({
    super.key,
    this.profile,
    this.fallbackId,
    this.size = 56,
    this.backgroundColor,
  });

  final String? profile;
  final String? fallbackId;
  final double size;
  final Color? backgroundColor;

  static const Color _defaultPlaceholderBg = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    final bytes = _decodeImageBytes(profile);
    if (bytes != null && bytes.isNotEmpty) {
      return ClipOval(
        child: Image.memory(
          Uint8List.fromList(bytes),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor ?? _defaultPlaceholderBg,
      child: _placeholderContent(context),
    );
  }

  Widget _placeholderContent(BuildContext context) {
    final id = fallbackId?.trim();
    if (id != null && id.isNotEmpty) {
      final initials = _initialsFromId(id);
      if (initials.isNotEmpty) {
        return Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        );
      }
    }
    return Icon(
      LineAwesomeIcons.user,
      size: size * 0.5,
      color: Colors.grey.shade600,
    );
  }

  static String _initialsFromId(String id) {
    final parts = id.split(RegExp(r'[\s\-_]+'));
    if (parts.length >= 2) {
      final a = parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
      final b = parts[1].isNotEmpty ? parts[1][0].toUpperCase() : '';
      return '$a$b';
    }
    if (parts.isNotEmpty && parts.first.length >= 2) {
      return parts.first.substring(0, 2).toUpperCase();
    }
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return '';
  }

  /// Tries to decode [value] as base64 image bytes. Handles optional data URL prefix.
  static List<int>? _decodeImageBytes(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    String base64 = value.trim();
    final dataUri = RegExp(r'^data:image/[^;]+;base64,(.+)$', caseSensitive: false);
    final match = dataUri.firstMatch(base64);
    if (match != null) base64 = match.group(1) ?? base64;
    try {
      return base64Decode(base64);
    } catch (_) {
      return null;
    }
  }
}
