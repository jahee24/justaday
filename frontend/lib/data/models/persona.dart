import 'package:json_annotation/json_annotation.dart';

part 'persona.g.dart';

@JsonSerializable()
class Persona {
  final int id;
  final String code;
  final String name;
  final String role;
  final String tagline;
  final String description;
  final List<String> keywords;
  final String mentGuide;
  final String themeColor;

  const Persona({
    required this.id,
    required this.code,
    required this.name,
    required this.role,
    required this.tagline,
    required this.description,
    required this.keywords,
    required this.mentGuide,
    required this.themeColor,
  });

  factory Persona.fromJson(Map<String, dynamic> json) => _$PersonaFromJson(json);

  Map<String, dynamic> toJson() => _$PersonaToJson(this);
}
