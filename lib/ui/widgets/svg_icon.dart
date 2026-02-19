import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Displays an SVG icon from assets/svg with optional color and size.
class SvgIcon extends StatelessWidget {
  const SvgIcon(
    this.assetPath, {
    super.key,
    this.size = 24,
    this.color,
    this.fit = BoxFit.contain,
  });

  final String assetPath;
  final double size;
  final Color? color;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      fit: fit,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}

/// Centralized paths for SVG icons in assets/svg/
class AppSvgIcons {
  AppSvgIcons._();

  static const String _base = 'assets/svg';

  static const String home = '$_base/fi-rr-home.svg';
  static const String graduationCap = '$_base/fi-rr-graduation-cap.svg';
  static const String heart = '$_base/fi-rr-heart.svg';
  static const String user = '$_base/fi-rr-user.svg';
  static const String refresh = '$_base/fi-br-refresh.svg';
  static const String upload = '$_base/fi-br-upload.svg';
  static const String download = '$_base/fi-br-download.svg';
  static const String scan = '$_base/scan.svg';
  static const String crossCircle = '$_base/fi-rr-cross-circle.svg';
}
