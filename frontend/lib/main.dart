import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/navigation/navigation_service.dart';
import 'package:frontend/state/auth_provider.dart';
import 'package:frontend/state/journal_provider.dart';
import 'package:frontend/ui/auth/login_signup_screen.dart';
import 'package:frontend/ui/persona/persona_setting_screen.dart';
import 'package:frontend/ui/journal/main_record_screen.dart';
import 'package:frontend/ui/journal/feedback_screen.dart';
import 'package:frontend/ui/journal/feedback_list_screen.dart';
import 'package:frontend/ui/profile/name_setting_screen.dart';
import 'package:frontend/ui/profile/setting_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<JournalProvider>(create: (_) => JournalProvider()),
      ],
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        title: 'Just A Day',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginSignupScreen(),
          '/persona': (_) => const PersonaSettingScreen(),
          '/name': (_) => const NameSettingScreen(),
          '/record': (_) => const MainRecordScreen(),
          // '/feedback': (_) => const MainRecordScreen(),
          '/feedback-list': (_) => const FeedbackListScreen(),
          '/settings': (_) => const SettingScreen(),
        },
      ),
    );
  }
}
