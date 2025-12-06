// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persona.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Persona _$PersonaFromJson(Map<String, dynamic> json) => Persona(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  name: json['name'] as String,
  role: json['role'] as String,
  tagline: json['tagline'] as String,
  description: json['description'] as String,
  keywords: (json['keywords'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  mentGuide: json['mentGuide'] as String,
  themeColor: json['themeColor'] as String,
);

Map<String, dynamic> _$PersonaToJson(Persona instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'role': instance.role,
  'tagline': instance.tagline,
  'description': instance.description,
  'keywords': instance.keywords,
  'mentGuide': instance.mentGuide,
  'themeColor': instance.themeColor,
};
