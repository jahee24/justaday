import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:justaday/data/api/dio_client.dart';
import 'package:justaday/data/api/log_error_service.dart';
import 'package:justaday/data/models/ai_response.dart';
import 'package:justaday/ui/common/app_menu_button.dart';
import 'package:intl/intl.dart';

class FeedbackListScreen extends StatefulWidget {
  const FeedbackListScreen({super.key});

  @override
  State<FeedbackListScreen> createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends State<FeedbackListScreen> {
  late Future<List<AIResponse>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchFeedbacks();
  }

  Future<List<AIResponse>> _fetchFeedbacks() async {
    try {
      final Response<dynamic> res = await DioClient.dio.get<dynamic>(
        'https://divine-tenderness-production-9284.up.railway.app/api/v1/log/getall',
      );
      if (res.data is List<dynamic>) {
        final List<dynamic> list = res.data as List<dynamic>;
        return list
            .whereType<Map<String, dynamic>>()
            .map(AIResponse.fromJson)
            .toList();
      }
    } on DioException catch (e) {
      final String errorMsg = '피드백 목록 조회 실패: ${e.response?.statusCode} - ${e.message}';
      await LogErrorService.report(errorMsg);
      if (e.response?.statusCode == 401) {
        throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
      }
      throw Exception('피드백을 불러오지 못했습니다.');
    } catch (e) {
      await LogErrorService.report('피드백 목록 조회 실패: $e');
      throw Exception('피드백을 불러오지 못했습니다.');
    }
    throw Exception('피드백을 불러오지 못했습니다.');
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _fetchFeedbacks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('저널 및 피드백 기록'),
        actions: const <Widget>[AppMenuButton()],
      ),
      body: FutureBuilder<List<AIResponse>>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<List<AIResponse>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(snapshot.error.toString()),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }
          final List<AIResponse> data = snapshot.data ?? <AIResponse>[];
          if (data.isEmpty) {
            return const Center(child: Text('작성한 저널이 없습니다.'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                final AIResponse item = data[index];
                
                final DateTime? journalDate = item.journalDate;
                final String title = journalDate != null
                    ? DateFormat('yyyy년 MM월 dd일').format(journalDate)
                    : '날짜 정보 없음';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                  child: ExpansionTile(
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      item.content ?? '저널 내용이 없습니다.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _buildSectionTitle('내가 쓴 저널'),
                            Text(item.content ?? '저널 내용이 없습니다.'),
                            const SizedBox(height: 24),
                            
                            _buildSectionTitle('AI의 피드백'),
                            Text(
                              item.mentText.isEmpty ? '피드백이 아직 준비되지 않았습니다.' : item.mentText,
                              style: const TextStyle(fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 16),

                            if (item.miniPlans.isNotEmpty) ...[
                              _buildSectionTitle('미니 플랜'),
                              ...item.miniPlans.map((plan) => ListTile(
                                leading: const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                                title: Text(plan),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              )),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
      ),
    );
  }
}
