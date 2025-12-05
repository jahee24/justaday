// lib/ui/common/app_menu_button.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/navigation/navigation_service.dart';
import 'package:frontend/data/auth/auth_service.dart';
import 'package:frontend/data/api/journal_service.dart';
import 'package:frontend/data/models/ai_response.dart';
import 'package:frontend/data/user/user_service.dart';

class AppMenuButton extends StatelessWidget {
  const AppMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (String value) => _handleMenuSelection(context, value),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'journal_input',
          child: Row(
            children: <Widget>[
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('저널 입력'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'journal_view',
          child: Row(
            children: <Widget>[
              Icon(Icons.list, size: 20),
              SizedBox(width: 8),
              Text('저널 보기'),
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
        const PopupMenuItem<String>(
          value: 'persona_change',
          child: Row(
            children: <Widget>[
              Icon(Icons.person, size: 20),
              SizedBox(width: 8),
              Text('페르소나 변경'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'name_setting',
          child: Row(
            children: <Widget>[
              Icon(Icons.badge, size: 20),
              SizedBox(width: 8),
              Text('이름 설정/확인'),
            ],
          ),
        ),
        const PopupMenuDivider(),
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
      case 'journal_input':
        await _handleJournalInput();
        break;
      case 'journal_view':
        // TODO: 저널 보기 화면 구현 시 추가
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저널 보기 기능은 준비 중입니다.')),
        );
        break;
      case 'feedback_list':
        await NavigationService.navigateToFeedbackList();
        break;
      case 'persona_change':
        await NavigationService.navigateToPersona();
        break;
      case 'name_setting':
        await NavigationService.navigateToNameSetting(replace: false);
        break;
      case 'logout':
        await _handleLogout(context);
        break;
    }
  }

  Future<void> _handleJournalInput() async {
    AIResponse? todayFeedback =
        await JournalService.instance.fetchTodayJournalFeedback();

    if (todayFeedback != null) {
      await UserService.instance.saveLastFeedback(todayFeedback);
      await NavigationService.navigateToFeedback(
        arguments: todayFeedback,
        replace: true,
      );
      return;
    }

    await NavigationService.navigateToRecord(replace: true);
  }

  Future<void> _handleLogout(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.instance.deleteToken();
      await UserService.instance.clearUserData();
      await NavigationService.navigateToLoginAndClear();
    }
  }
}

