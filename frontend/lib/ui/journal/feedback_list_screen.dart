import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/data/api/dio_client.dart';
import 'package:frontend/data/api/log_error_service.dart';
import 'package:frontend/data/models/ai_response.dart';
import 'package:frontend/ui/common/app_menu_button.dart';

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
        title: const Text('AI 피드백 기록'),
        actions: const <Widget>[AppMenuButton()],
      ),
      body: FutureBuilder<List<AIResponse>>(
        future: _future,
        builder:
            (BuildContext context, AsyncSnapshot<List<AIResponse>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('피드백을 불러올 수 없습니다.'),
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
            return const Center(child: Text('표시할 피드백이 없습니다.'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                final AIResponse item = data[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.mentText.isEmpty
                              ? '멘트가 없습니다.'
                              : item.mentText,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        if (item.miniPlans.isEmpty)
                          const Text('- 미니 플랜 없음 -')
                        else
                          ...item.miniPlans.asMap().entries.map(
                                (MapEntry<int, String> e) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Text('${e.key + 1}. ${e.value}'),
                                ),
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


