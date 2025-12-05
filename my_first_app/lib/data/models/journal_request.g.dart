// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JournalRequest _$JournalRequestFromJson(Map<String, dynamic> json) =>
    JournalRequest(
      status: (json['status'] as num).toInt(),
      journalAction: json['journalAction'] as String,
      journalEmotion: json['journalEmotion'] as String,
      journalContext: json['journalContext'] as String,
    );

Map<String, dynamic> _$JournalRequestToJson(JournalRequest instance) =>
    <String, dynamic>{
      'status': instance.status,
      'journalAction': instance.journalAction,
      'journalEmotion': instance.journalEmotion,
      'journalContext': instance.journalContext,
    };
