---
last_updated: 2026-01-28
---

# Project Profile

## Detected profile (auto)

- **Project name**: `operator_mobile_app`
- **Type**: Frontend (mobile-first), Flutter application
- **Primary language**: Dart
- **Framework**: Flutter
- **Dart SDK constraint**: `^3.9.2` (from `pubspec.yaml`)
- **Flutter platforms present**: Android, iOS, Web, Windows, macOS, Linux

## Package management / build

- **Package manager**: `flutter pub` (Pub)
- **Key manifest**: `pubspec.yaml`
- **Android build**: Gradle (`android/build.gradle.kts`)
- **iOS build**: Xcode project (`ios/Runner.xcodeproj`)

## Current app entry points

- **Dart entry**: `lib/main.dart`
- **Default test**: `test/widget_test.dart`
- **Lint config**: `analysis_options.yaml`

## Architectural intent (project decision)

- **State management**: **GetX** (selected)
  - Note: Add `get` dependency to `pubspec.yaml` when you start implementing features requiring GetX runtime.

## Constraints / assumptions

- This is a newly created Flutter project; architecture beyond the default template is not yet established.
- The AI must not invent domain models or APIs; it must ask structured questions first.
