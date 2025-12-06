// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIResponse _$AIResponseFromJson(Map<String, dynamic> json) => AIResponse(
  content: json['content'] as String?,
  journalDate: _dateTimeFromJson(json['journalDate'] as String?),
  mentText: json['mentText'] as String,
  miniPlans: (json['miniPlans'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  responseCode: (json['responseCode'] as num).toInt(),
);

Map<String, dynamic> _$AIResponseToJson(AIResponse instance) =>
    <String, dynamic>{
      'content': instance.content,
      'journalDate': _dateTimeToJson(instance.journalDate),
      'mentText': instance.mentText,
      'miniPlans': instance.miniPlans,
      'responseCode': instance.responseCode,
    };
