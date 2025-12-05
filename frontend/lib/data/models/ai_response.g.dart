// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIResponse _$AIResponseFromJson(Map<String, dynamic> json) => AIResponse(
  mentText: json['mentText'] as String,
  miniPlans: (json['miniPlans'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  responseCode: (json['responseCode'] as num).toInt(),
);

Map<String, dynamic> _$AIResponseToJson(AIResponse instance) =>
    <String, dynamic>{
      'mentText': instance.mentText,
      'miniPlans': instance.miniPlans,
      'responseCode': instance.responseCode,
    };
///Users/hee/cursor/prac1/my_first_app/lib/data/models/ai_response.g.dart