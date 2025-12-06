import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/state/journal_provider.dart';
import 'package:frontend/ui/common/app_menu_button.dart';
import 'package:frontend/ui/journal/widgets/journal_entry_form.dart';
import 'package:frontend/ui/journal/widgets/today_feedback_view.dart';

class MainRecordScreen extends StatefulWidget {
  const MainRecordScreen({super.key});

  @override
  State<MainRecordScreen> createState() => _MainRecordScreenState();
}

class _MainRecordScreenState extends State<MainRecordScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 처음 빌드된 후, 상태 확인을 시작합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JournalProvider>().checkSubmissionStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    // JournalProvider의 상태를 감지합니다.
    final journalProvider = context.watch<JournalProvider>();

    return Scaffold(
      appBar: AppBar(
        // 1. AppBar 제목을 상태에 따라 동적으로 변경합니다.
        title: Text(
          journalProvider.hasSubmittedToday ? '오늘의 피드백' : '저널 입력',
        ),
        // 3-2. AppMenuButton은 항상 여기에 존재합니다.
        actions: const [AppMenuButton()],
      ),
      // body도 상태에 따라 동적으로 변경됩니다.
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildBody(journalProvider),
      ),
    );
  }

  Widget _buildBody(JournalProvider journalProvider) {
    // 상태 확인 중일 때는 로딩 인디케이터를 보여줍니다.
    if (journalProvider.isCheckingStatus) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(),
      );
    }

    // 오늘 저널을 이미 제출했다면 TodayFeedbackView를 보여줍니다.
    if (journalProvider.hasSubmittedToday) {
      // 2. Provider가 가진 최신 피드백 데이터를 전달합니다.
      if (journalProvider.latestFeedback != null) {
        return TodayFeedbackView(
          key: const ValueKey('feedback'),
          feedback: journalProvider.latestFeedback!,
        );
      }
      // 피드백 데이터가 아직 없다면 (폴링 중 등) 로딩을 표시합니다.
      return const Center(
        key: ValueKey('feedback_loading'),
        child: CircularProgressIndicator(),
      );
    }

    // 저널을 아직 제출하지 않았다면 입력 폼을 보여줍니다.
    return const JournalEntryForm(
      key: ValueKey('form'),
    );
  }
}
