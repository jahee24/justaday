import 'package:flutter/material.dart';
import 'package:justaday/core/navigation/navigation_service.dart';
import 'package:justaday/ui/common/app_menu_button.dart';
import 'package:provider/provider.dart';
import 'package:justaday/state/auth_provider.dart';
import 'package:justaday/state/journal_provider.dart';
import 'package:justaday/data/api/dio_client.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        actions: const [AppMenuButton()],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('페르소나 변경'),
            onTap: () {
              NavigationService.navigateToPersona(replace: false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.badge),
            title: const Text('이름 설정/확인'),
            onTap: () {
              NavigationService.navigateToNameSetting(replace: false);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text('문의하기'),
            onTap: () {
              _launchEmail(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('개인정보 처리방침'),
            onTap: () {
              _launchPrivacyPolicy(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('계정 탈퇴', style: TextStyle(color: Colors.red)),
            onTap: () {
              _showDeleteAccountDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'jahee24.dev@gmail.com',
      queryParameters: {'subject': '[Just A Day] 문의 및 오류 신고'},
    );
    try {
      if (!await launchUrl(emailLaunchUri)) {
        throw 'Could not launch ${emailLaunchUri.toString()}';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('메일 앱을 열 수 없습니다. 기기에 메일 앱이 설치되어 있는지 확인해주세요.')),
      );
    }
  }

  Future<void> _launchPrivacyPolicy(BuildContext context) async {
    final Uri privacyPolicyUrl = Uri.parse('https://jahee24.github.io/justaday_Privacy/');
    try {
      if (!await launchUrl(privacyPolicyUrl, mode: LaunchMode.inAppWebView)) {
        throw 'Could not launch ${privacyPolicyUrl.toString()}';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크를 열 수 없습니다. 잠시 후 다시 시도해주세요.')),
      );
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('계정 탈퇴'),
          content: const Text('정말로 계정을 탈퇴하시겠습니까?\n모든 저널과 피드백 기록이 영구적으로 삭제되며, 복구할 수 없습니다.'),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('탈퇴하기', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  await DioClient.dio.delete('/api/v1/user');
                  Navigator.of(dialogContext).pop();

                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final journalProvider = Provider.of<JournalProvider>(context, listen: false);

                  await NavigationService.navigateToLoginAndClear();
                  await Future.delayed(const Duration(milliseconds: 50));
                  journalProvider.resetState();
                  await authProvider.logout();

                } catch (e) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('계정 탈퇴 중 오류가 발생했습니다: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
