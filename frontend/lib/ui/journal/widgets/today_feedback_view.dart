import 'package:flutter/material.dart';
import 'package:frontend/data/models/ai_response.dart';
import 'package:intl/intl.dart';

class TodayFeedbackView extends StatelessWidget {
  final AIResponse feedback;

  const TodayFeedbackView({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    // responseCode가 102이면 아직 피드백 준비 중
    if (feedback.responseCode == 102) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AI가 피드백을 생성 중입니다...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('AI의 피드백'),
          _buildFeedbackCard(feedback),
          const SizedBox(height: 24),
          _buildSectionTitle('내가 쓴 저널'),
          _buildJournalCard(feedback),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
      ),
    );
  }

  Widget _buildFeedbackCard(AIResponse feedback) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              feedback.mentText.isEmpty ? '피드백이 아직 준비되지 않았습니다.' : feedback.mentText,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            if (feedback.miniPlans.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('미니 플랜', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...feedback.miniPlans.map((plan) => ListTile(
                leading: const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                title: Text(plan),
                dense: true,
                contentPadding: EdgeInsets.zero,
              )),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildJournalCard(AIResponse feedback) {
    final DateTime? journalDate = feedback.journalDate;
    final String title = journalDate != null
        ? DateFormat('yyyy년 MM월 dd일').format(journalDate)
        : '날짜 정보 없음';

    return Card(
      elevation: 2,
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
            const Divider(height: 20),
            Text(feedback.content ?? '저널 내용이 없습니다.', style: TextStyle(fontSize: 15, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}
