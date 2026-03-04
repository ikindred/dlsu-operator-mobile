import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

/// Shows a dialog when the user tries to sync or upload while in offline mode.
/// [action] is a short description, e.g. 'sync students' or 'upload student logs'.
void showOfflineLoginRequiredDialog(String action) {
  Get.dialog(
    AlertDialog(
      title: const Text('Offline mode'),
      content: Text(
        'You are currently using the app in offline mode. To $action you need to sign in to your account. Would you like to go to the login page?',
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Not now'),
        ),
        TextButton(
          onPressed: () {
            Get.back();
            Get.offAllNamed(AppRoutes.LOGIN);
          },
          child: const Text('Sign in'),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}
