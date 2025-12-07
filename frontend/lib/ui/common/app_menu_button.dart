// frontend/lib/ui/common/app_menu_button.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/navigation/navigation_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend/state/auth_provider.dart';
import 'package:frontend/state/journal_provider.dart';

class AppMenuButton extends StatelessWidget {
  const AppMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool hasSubmittedToday = context.watch<JournalProvider>().hasSubmittedToday;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (String value) => _handleMenuSelection(context, value),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        // '저널 입력' 또는 '오늘의 피드백' 메뉴
        PopupMenuItem<String>(
          value: 'journal_main',
          child: Row(
            children: <Widget>[
              Icon(hasSubmittedToday ? Icons.visibility : Icons.edit, size: 20),
              const SizedBox(width: 8),
              Text(hasSubmittedToday ? '오늘의 피드백' : '저널 입력'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'feedback_list',
          child: Row(
            children: <Widget>[
              Icon(Icons.chat_bubble_outline, size: 20),
              SizedBox(width: 8),
              Text('피드백 기록'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: <Widget>[
              Icon(Icons.settings, size: 20),
              SizedBox(width: 8),
              Text('설정'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: <Widget>[
              Icon(Icons.logout, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('로그아웃', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleMenuSelection(BuildContext context, String value) async {
    switch (value) {
      case 'journal_main':
        if (ModalRoute.of(context)?.settings.name != '/record') {
          await NavigationService.navigateToRecord(replace: true);
        }
        context.read<JournalProvider>().checkSubmissionStatus();
        break;
      case 'feedback_list':
        await NavigationService.navigateToFeedbackList();
        break;
      case 'settings':
        await NavigationService.navigateToSettings();
        break;
      case 'logout':
        await _handleLogout(context);
        break;
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('로그아웃')),
        ],
      ),
    );

    if (confirm == true) {
      // 1. 다른 Provider들의 상태를 먼저 초기화
      journalProvider.resetState();

      // 2. AuthProvider의 로그아웃 로직(데이터 삭제) 호출
      await authProvider.logout();

      // 3. 모든 작업이 끝난 후, 화면을 안전하게 전환
      await NavigationService.navigateToLoginAndClear();
    }
  }
}
