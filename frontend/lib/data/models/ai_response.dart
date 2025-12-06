import 'package:json_annotation/json_annotation.dart';

part 'ai_response.g.dart';

// JSON의 날짜 문자열(예: "2024-07-27")을 DateTime으로 변환하는 함수
DateTime? _dateTimeFromJson(String? json) => json == null ? null : DateTime.parse(json);
// DateTime을 JSON 날짜 문자열로 변환하는 함수 (지금은 필요 없지만 완전성을 위해 추가)
String? _dateTimeToJson(DateTime? time) => time?.toIso8601String().split('T').first;

@JsonSerializable()
class AIResponse {
  final String? content;
  
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? journalDate;

  final String mentText;
  final List<String> miniPlans;
  final int responseCode;

  const AIResponse({
    this.content,
    this.journalDate,
    required this.mentText,
    required this.miniPlans,
    required this.responseCode,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) =>
      _$AIResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AIResponseToJson(this);
}
