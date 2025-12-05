import 'package:json_annotation/json_annotation.dart';

part 'ai_response.g.dart';

@JsonSerializable()
class AIResponse {
  final String mentText;
  final List<String> miniPlans;
  final int responseCode;

  const AIResponse({
    required this.mentText,
    required this.miniPlans,
    required this.responseCode,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) =>
      _$AIResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AIResponseToJson(this);
}


