import 'package:dio/dio.dart';
import 'package:frontend/data/api/dio_client.dart';
import 'package:frontend/data/models/persona.dart';

class PersonaService {
  PersonaService._();
  static final PersonaService instance = PersonaService._();

  final Dio _dio = DioClient.dio;

  Future<List<Persona>> fetchPersonas() async {
    try {
      final response = await _dio.get<List<dynamic>>('/api/v1/personas');
      if (response.data != null) {
        return response.data!
            .whereType<Map<String, dynamic>>()
            .map((json) => Persona.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      // print('Failed to fetch personas: $e');
      throw Exception('페르소나 목록을 불러오는 데 실패했습니다.');
    }
  }
}
