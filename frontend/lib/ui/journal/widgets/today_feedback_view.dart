import 'package:flutter/material.dart';
import 'package:justaday/data/models/ai_response.dart';
import 'package:justaday/data/user/user_service.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class TodayFeedbackView extends StatefulWidget {
  final AIResponse feedback;
  const TodayFeedbackView({super.key, required this.feedback});

  @override
  State<TodayFeedbackView> createState() => _TodayFeedbackViewState();
}

class _TodayFeedbackViewState extends State<TodayFeedbackView> {
  String _supportMessage = '';

  @override
  void initState() {
    super.initState();
    _setSupportMessage();
  }

  Future<void> _setSupportMessage() async {
    final personaId = await UserService.instance.getPersonaId();
    setState(() {
      _supportMessage = _getSupportMessage(personaId);
    });
  }

  String _getSupportMessage(int? personaId) {
    final mirMessages = [
      "오늘 하루의 마음을 여기에 솔직하게 적어 내려간 것만으로도, 당신은 어제보다 한 뼘 더 자란 거예요.",
      "복잡했던 생각들을 글로 꺼내놓았군요. 정말 수고했어요. 이 기록들이 모여서 당신이 가고 싶은 곳으로 이끄는 반짝이는 별자리가 되어줄 거예요.",
      "힘들었죠? 그래도 피하지 않고 하루를 기록한 당신이 정말 자랑스러워요. 지금 이 순간, 당신은 이미 더 나은 내일을 향해 걸어가고 있는 중이에요.",
    ];
    final harryMessages = [
      "오늘의 기록은 막연한 감정이 아니라, 당신의 목표 달성 확률을 높이는 확실한 '데이터'로 축적되었습니다.",
      "성공은 우연이 아니라 설계되는 것입니다. 오늘 당신이 남긴 기록은 미래의 시행착오를 줄이는 가장 강력한 근거가 될 겁니다.",
      "오늘도 하루를 객관화하는 데 성공하셨군요. 이 행위만으로도 당신은 상위 1%의 성장 궤도에 진입했습니다.",
    ];
    final odenMessages = [
      "소란스러운 세상 속에서도 펜을 들어 하루를 매듭지었군요. 이 고요한 성찰의 시간이야말로 당신을 위대한 곳으로 이끄는 가장 정직한 나침반이라네.",
      "감정은 흘러가지만, 기록된 지혜는 남는 법이지. 오늘 자네가 남긴 이 발자국은 흔들리는 파도 속에서도 중심을 잡게 해 줄 묵직한 닻이 될 걸세.",
      "수고했네. 하루를 돌아보는 용기를 가진 사람은 결코 길을 잃지 않아. 자네는 방금, 스스로의 영혼을 한 단계 더 깊게 만든 걸세.",
    ];

    final messages = {
      1: mirMessages,
      2: harryMessages,
      3: odenMessages,
    };

    final random = Random();
    final messageList = messages[personaId] ?? mirMessages;
    return messageList[random.nextInt(messageList.length)];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.feedback.responseCode == 102) {
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
          if (_supportMessage.isNotEmpty) ...[
            Text(_supportMessage, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
          ],
          _buildSectionTitle('AI의 피드백'),
          _buildFeedbackCard(widget.feedback),
          const SizedBox(height: 24),
          _buildSectionTitle('내가 쓴 저널'),
          _buildJournalCard(widget.feedback),
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
