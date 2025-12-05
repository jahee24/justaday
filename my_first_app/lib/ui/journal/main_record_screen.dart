//lib/ui/journal/main_record_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_first_app/core/navigation/navigation_service.dart';
import 'package:my_first_app/data/api/journal_service.dart';
import 'package:my_first_app/data/models/ai_response.dart';
import 'package:my_first_app/data/models/journal_request.dart';
import 'package:my_first_app/data/user/user_service.dart';
import 'package:my_first_app/state/journal_provider.dart';
import 'package:my_first_app/ui/common/app_menu_button.dart';

class MainRecordScreen extends StatefulWidget {
  const MainRecordScreen({super.key});

  @override
  State<MainRecordScreen> createState() => _MainRecordScreenState();
}

class _MainRecordScreenState extends State<MainRecordScreen> {
  final TextEditingController _actionController = TextEditingController();
  final TextEditingController _emotionController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();
  int _status = 1;
  String? _userName;
  int? _personaId;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final String? name = await UserService.instance.getUserName();
    final int? personaId = await UserService.instance.getPersonaId();
    if (!mounted) return;
    setState(() {
      _userName = name ?? '';
      _personaId = personaId;
    });

    final AIResponse? todayFeedback =
        await JournalService.instance.fetchTodayJournalFeedback();
    if (todayFeedback != null) {
      await _redirectToFeedback(todayFeedback);
    }
  }

  Future<void> _redirectToFeedback(AIResponse feedback) async {
    await UserService.instance.saveLastFeedback(feedback);
    if (!mounted) return;
    await NavigationService.navigateToFeedback(
      arguments: feedback,
      replace: true,
    );
  }

  @override
  void dispose() {
    _actionController.dispose();
    _emotionController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final JournalProvider journal = context.watch<JournalProvider>();
    final String greeting = _buildGreeting();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Record'),
        actions: const <Widget>[AppMenuButton()],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: <Widget>[
                Opacity(
                  opacity: journal.isSubmitting ? 0.4 : 1.0,
                  child: IgnorePointer(
                    ignoring: journal.isSubmitting,
                    child: ListView(
                      children: <Widget>[
                        if (greeting.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              greeting,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ),
                        const Text('Status (1~3)'),
                        Slider(
                          value: _status.toDouble(),
                          min: 1,
                          max: 3,
                          divisions: 2,
                          label: _status.toString(),
                          onChanged: (double v) => setState(() => _status = v.round()),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _actionController,
                          decoration: const InputDecoration(labelText: 'journalAction'),
                          minLines: 1,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _emotionController,
                          decoration: const InputDecoration(labelText: 'journalEmotion'),
                          minLines: 1,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _contextController,
                          decoration: const InputDecoration(labelText: 'journalContext'),
                          minLines: 1,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                        ),
                        const SizedBox(height: 20),
                        if (journal.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(journal.error!, style: const TextStyle(color: Colors.red)),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: journal.isSubmitting
                                ? null
                                : () {
                                    final JournalRequest req = JournalRequest(
                                      status: _status,
                                      journalAction: _actionController.text.trim(),
                                      journalEmotion: _emotionController.text.trim(),
                                      journalContext: _contextController.text.trim(),
                                    );
                                    journal.submitJournal(req);
                                  },
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (journal.isSubmitting)
                  const Center(
                    child: _LoadingOverlay(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const <Widget>[
        SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        SizedBox(height: 12),
        Text('AI가 생각을 정리 중이에요...'),
      ],
    );
  }
}

String _personaGreeting(int? personaId) {
  switch (personaId) {
    case 1:
      return '따뜻한 루미가 함께할게요. 오늘 하루도 수고 많았어요.';
    case 2:
      return '차분한 아리아가 곁에 있어요. 편안하게 마음을 풀어주세요.';
    case 3:
      return '활기찬 네온이 함께 합니다. 솔직하게 이야기를 나눠볼까요?';
    default:
      return '반가워요. 오늘 하루도 수고 많았어요. 편안하게 기록해 주세요.';
  }
}

extension _MainRecordScreenGreeting on _MainRecordScreenState {
  String _buildGreeting() {
    if (_userName == null || _userName!.isEmpty) {
      return '';
    }
    final String personaText = _personaGreeting(_personaId);
    return '$_userName님, $personaText';
  }
}


