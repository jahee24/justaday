import 'package:flutter/material.dart';

class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> navigateToLoginAndClear() async {
    final NavigatorState? navigator = navigatorKey.currentState;
    if (navigator == null) return;
    await navigator.pushNamedAndRemoveUntil('/login', (Route<dynamic> _) => false);
  }

  static Future<void> navigateToPersona({bool replace = true}) async {
    final NavigatorState? navigator = navigatorKey.currentState;
    if (navigator == null) return;
    if (replace) {
      await navigator.pushReplacementNamed('/persona');
    } else {
      await navigator.pushNamed('/persona');
    }
  }

  static Future<void> navigateToRecord({bool replace = true}) async {
    final NavigatorState? navigator = navigatorKey.currentState;
    if (navigator == null) return;
    if (replace) {
      await navigator.pushReplacementNamed('/record');
    } else {
      await navigator.pushNamed('/record');
    }
  }

  static Future<void> navigateToNameSetting({bool replace = true}) async {
    final NavigatorState? navigator = navigatorKey.currentState;
    if (navigator == null) return;
    if (replace) {
      await navigator.pushReplacementNamed('/name');
    } else {
      await navigator.pushNamed('/name');
    }
  }

  static Future<void> navigateToFeedback({
    Object? arguments,
    bool replace = false,
  }) async {
    final NavigatorState? navigator = navigatorKey.currentState;
    if (navigator == null) return;
    if (replace) {
      await navigator.pushReplacementNamed('/feedback', arguments: arguments);
    } else {
      await navigator.pushNamed('/feedback', arguments: arguments);
    }
  }

  static Future<void> navigateToFeedbackList({bool replace = false}) async {
    final NavigatorState? navigator = navigatorKey.currentState;
    if (navigator == null) return;
    if (replace) {
      await navigator.pushReplacementNamed('/feedback-list');
    } else {
      await navigator.pushNamed('/feedback-list');
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


