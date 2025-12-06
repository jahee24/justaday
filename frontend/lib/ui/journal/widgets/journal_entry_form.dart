import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/state/journal_provider.dart';
import 'package:frontend/data/models/journal_request.dart';

class JournalEntryForm extends StatefulWidget {
  const JournalEntryForm({super.key});

  @override
  State<JournalEntryForm> createState() => _JournalEntryFormState();
}

class _JournalEntryFormState extends State<JournalEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _statusController = TextEditingController();
  final _actionController = TextEditingController();
  final _emotionController = TextEditingController();
  final _contextController = TextEditingController();

  @override
  void dispose() {
    _statusController.dispose();
    _actionController.dispose();
    _emotionController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  void _submit() {
    // 요구사항 5: 빈칸 있으면 제출 불가
    if (_formKey.currentState!.validate()) {
      final request = JournalRequest(
        status: int.tryParse(_statusController.text) ?? 0,
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
            TextFormField(
              controller: _statusController,
              decoration: const InputDecoration(labelText: '상태 레벨 (숫자)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '상태 레벨을 입력해주세요.';
                }
                if (int.tryParse(value) == null) {
                  return '숫자만 입력해주세요.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _actionController,
              decoration: const InputDecoration(labelText: '행동'),
              validator: (value) => (value == null || value.isEmpty) ? '행동을 입력해주세요.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emotionController,
              decoration: const InputDecoration(labelText: '감정'),
              validator: (value) => (value == null || value.isEmpty) ? '감정을 입력해주세요.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contextController,
              decoration: const InputDecoration(labelText: '상황'),
              maxLines: 5,
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
