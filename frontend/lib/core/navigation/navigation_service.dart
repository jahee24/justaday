import 'package:flutter/material.dart';

class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> navigateToLoginAndClear() async {
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (Route<dynamic> _) => false);
  }

  static Future<void> navigateToPersona({bool replace = true}) async {
    if (replace) {
      await navigatorKey.currentState?.pushReplacementNamed('/persona');
    } else {
      await navigatorKey.currentState?.pushNamed('/persona');
    }
  }

  static Future<void> navigateToRecord({bool replace = true}) async {
    if (replace) {
      await navigatorKey.currentState?.pushReplacementNamed('/record');
    } else {
      await navigatorKey.currentState?.pushNamed('/record');
    }
  }

  static Future<void> navigateToNameSetting({bool replace = true}) async {
    if (replace) {
      await navigatorKey.currentState?.pushReplacementNamed('/name');
    } else {
      await navigatorKey.currentState?.pushNamed('/name');
    }
  }

  static Future<void> navigateToSettings() async {
    await navigatorKey.currentState?.pushNamed('/settings');
  }

  static Future<void> navigateToFeedback({
    Object? arguments,
    bool replace = false,
  }) async {
    if (replace) {
      await navigatorKey.currentState?.pushReplacementNamed('/feedback', arguments: arguments);
    } else {
      await navigatorKey.currentState?.pushNamed('/feedback', arguments: arguments);
    }
  }

  static Future<void> navigateToFeedbackList({bool replace = false}) async {
    if (replace) {
      await navigatorKey.currentState?.pushReplacementNamed('/feedback-list');
    } else {
      await navigatorKey.currentState?.pushNamed('/feedback-list');
    }
  }

  static Future<void> showTemporaryErrorDialog({
    String message = '일시적인 오류가 발생했습니다. 잠시후 다시 시도해주세요.',
  }) async {
    final BuildContext? context = navigatorKey.currentContext;
    if (context == null) return;
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('알림'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
