//lib/data/models/journal_request.dart
import 'package:json_annotation/json_annotation.dart';

part 'journal_request.g.dart';

@JsonSerializable()
class JournalRequest {
  /// 1~3 범위의 상태 레벨
  final int status;
  final String journalAction;
  final String journalEmotion;
  final String journalContext;

  const JournalRequest({
    required this.status,
    required this.journalAction,
    required this.journalEmotion,
    required this.journalContext,
  }) : assert(status >= 1 && status <= 3, 'status must be in 1..3');

  factory JournalRequest.fromJson(Map<String, dynamic> json) =>
      _$JournalRequestFromJson(json);

  Map<String, dynamic> toJson() => _$JournalRequestToJson(this);
}


