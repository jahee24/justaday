// lib/ui/persona/persona_setting_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/data/api/persona_service.dart';
import 'package:frontend/data/models/persona.dart';
import 'package:frontend/data/user/user_service.dart';
import 'package:frontend/core/navigation/navigation_service.dart';
import 'package:dio/dio.dart';
import 'package:frontend/data/api/dio_client.dart';

// import 'package:frontend/data/user/user_service.dart';
import 'package:frontend/ui/common/app_menu_button.dart';

class PersonaSettingScreen extends StatefulWidget {
  const PersonaSettingScreen({super.key});

  @override
  State<PersonaSettingScreen> createState() => _PersonaSettingScreenState();
}

class _PersonaSettingScreenState extends State<PersonaSettingScreen> {
  late Future<List<Persona>> _personasFuture;
  int? _selectedPersonaId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _personasFuture = PersonaService.instance.fetchPersonas();
  }

  Future<void> _updatePersona() async {
    if (_selectedPersonaId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('페르소나를 선택해주세요.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await DioClient.dio.post(
        '/api/v1/user/persona',
        data: {'personaId': _selectedPersonaId},
      );
      await UserService.instance.savePersonaId(_selectedPersonaId!);
      final bool hasName = await UserService.instance.hasUserName();
      if (hasName) {
        // 이름이 있으면 홈 화면(기록 화면)으로 이동
        await NavigationService.navigateToRecord(replace: true);
      } else {
        // 이름이 없으면 이름 설정 화면으로 이동
        await NavigationService.navigateToNameSetting(replace: true);
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류 발생: ${e.message}')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 페르소나 선택'),
        actions: const [AppMenuButton()],
      ),

      body: FutureBuilder<List<Persona>>(
        future: _personasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
              child: Text(snapshot.error?.toString() ?? '페르소나를 불러올 수 없습니다.'),
            );
          }

          final personas = snapshot.data!;
          final selectedPersona = _selectedPersonaId == null
              ? null
              : personas.firstWhere(
                  (p) => p.id == _selectedPersonaId,
                  orElse: () => personas.first,
                );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '당신과 함께할 AI 코치를 선택해주세요.',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  value: _selectedPersonaId,
                  hint: const Text('페르소나 선택...'),
                  items: personas.map((persona) {
                    return DropdownMenuItem<int>(
                      value: persona.id,
                      child: Text(persona.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPersonaId = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                if (selectedPersona != null)
                  Expanded(child: _buildPersonaDetails(selectedPersona)),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updatePersona,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('선택 완료'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonaDetails(Persona persona) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                persona.role,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(
                    int.parse('0xFF${persona.themeColor.substring(1)}'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '"${persona.tagline}"',
                style: const TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(persona.description),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8.0,
                children: persona.keywords
                    .map((keyword) => Chip(label: Text(keyword)))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
