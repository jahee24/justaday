import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/state/journal_provider.dart';
import 'package:frontend/data/models/journal_request.dart';
import 'package:frontend/data/user/user_service.dart';

class JournalEntryForm extends StatefulWidget {
  const JournalEntryForm({super.key});

  @override
  State<JournalEntryForm> createState() => _JournalEntryFormState();
}

class _JournalEntryFormState extends State<JournalEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _actionController = TextEditingController();
  final _emotionController = TextEditingController();
  final _contextController = TextEditingController();

  double _statusLevel = 3.0;
  String _greeting = '';

  @override
  void initState() {
    super.initState();
    _setGreeting();
  }

  Future<void> _setGreeting() async {
    final personaId = await UserService.instance.getPersonaId();
    final userName = await UserService.instance.getUserName() ?? '사용자';
    if (mounted) {
      setState(() {
        _greeting = _getGreetingMessage(personaId, userName);
      });
    }
  }

  String _getGreetingMessage(int? personaId, String userName) {
    final greetings = {
      1: "미르에게 $userName님의 하루를 알려주세요.",
      2: "오늘의 데이터를 입력하여 성장 궤도에 오르세요, $userName님.",
      3: "$userName님, 고요한 성찰의 시간입니다. 오늘의 페이지를 채워보세요.",
    };
    return greetings[personaId] ?? "$userName님, 안녕하세요. 오늘 하루는 어떠셨나요?";
  }

  @override
  void dispose() {
    _actionController.dispose();
    _emotionController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final request = JournalRequest(
        status: _statusLevel.round(),
        journalAction: _actionController.text,
        journalEmotion: _emotionController.text,
        journalContext: _contextController.text,
      );
      context.read<JournalProvider>().submitJournal(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    final journalProvider = context.watch<JournalProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (_greeting.isNotEmpty) ...[
              Text(_greeting, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
            ],
            
            // 1. 상태 레벨 Slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('오늘의 상태 레벨: ${_statusLevel.round()}', style: const TextStyle(fontSize: 16)),
                Slider(
                  value: _statusLevel,
                  min: 1,
                  max: 3,
                  divisions: 2,
                  label: _statusLevel.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _statusLevel = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. 자동 줄바꿈 TextFormField
            TextFormField(
              controller: _actionController,
              decoration: const InputDecoration(labelText: '행동'),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              validator: (value) => (value == null || value.isEmpty) ? '행동을 입력해주세요.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emotionController,
              decoration: const InputDecoration(labelText: '감정'),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              validator: (value) => (value == null || value.isEmpty) ? '감정을 입력해주세요.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contextController,
              decoration: const InputDecoration(labelText: '상황'),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              validator: (value) => (value == null || value.isEmpty) ? '상황을 입력해주세요.' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: journalProvider.isSubmitting ? null : _submit,
              child: journalProvider.isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('제출하기'),
            ),
            if (journalProvider.error != null) ...[
              const SizedBox(height: 12),
              Text(
                journalProvider.error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
