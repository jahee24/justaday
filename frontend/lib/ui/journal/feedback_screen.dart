// lib/ui/journal/feedback_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/navigation/navigation_service.dart';
import 'package:frontend/data/api/log_error_service.dart';
import 'package:frontend/data/models/ai_response.dart';
import 'package:frontend/data/user/user_service.dart';
import 'package:frontend/ui/common/app_menu_button.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String? _userName;
  AIResponse? _response;
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is AIResponse) {
      _response = args;
      UserService.instance.saveLastFeedback(args);
    }
    _loadData();
  }

  Future<void> _loadData() async {
    final String? name = await UserService.instance.getUserName();
    if (_response == null) {
      _response = await UserService.instance.getLastFeedback();
    }
    if (_response == null) {
      await LogErrorService.report('피드백 데이터를 불러올 수 없습니다.');
      await NavigationService.showTemporaryErrorDialog();
      await NavigationService.navigateToRecord(replace: true);
      return;
    }
    if (!mounted) return;
    setState(() {
      _userName = name ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        actions: const <Widget>[AppMenuButton()],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _response == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (_userName != null && _userName!.isNotEmpty)
                        Text(
                          '$_userName님, 오늘도 더 좋은 방향을 선택하셨네요. 대단해요.',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        _response!.mentText.isEmpty
                            ? '응답이 없습니다.'
                            : _response!.mentText,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text('Mini Plans',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      if (_response!.miniPlans.isEmpty)
                        const Text('- 없음 -')
                      else
                        ..._response!.miniPlans.asMap().entries.map(
                              (MapEntry<int, String> e) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('${e.key + 1}. '),
                                    Expanded(child: Text(e.value)),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}


