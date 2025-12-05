// lib/ui/persona/persona_setting_screen.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/navigation/navigation_service.dart';
import 'package:frontend/data/api/dio_client.dart';
import 'package:frontend/data/user/user_service.dart';
import 'package:frontend/ui/common/app_menu_button.dart';

class PersonaSettingScreen extends StatefulWidget {
  const PersonaSettingScreen({super.key});

  @override
  State<PersonaSettingScreen> createState() => _PersonaSettingScreenState();
}

class _PersonaSettingScreenState extends State<PersonaSettingScreen> {
  int? _selectedId;
  bool _isLoading = false;
  String? _error;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final String? name = await UserService.instance.getUserName();
    if (!mounted) return;
    setState(() => _userName = name);
  }

  Future<void> _submitPersona() async {
    if (_selectedId == null) {
      setState(() => _error = '페르소나를 선택해주세요.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final Dio dio = DioClient.dio;
    try {
      await dio.post<dynamic>(
        'https://divine-tenderness-production-9284.up.railway.app/api/v1/user/persona',
        data: <String, dynamic>{'personaId': _selectedId},
      );
      await UserService.instance.savePersonaId(_selectedId!);
      final bool hasName = await UserService.instance.hasUserName();
      if (!mounted) return;
      if (hasName) {
        await NavigationService.navigateToRecord();
      } else {
        await NavigationService.navigateToNameSetting(replace: true);
      }
    } on DioException catch (e) {
      setState(() => _error = e.message ?? '네트워크 오류가 발생했습니다.');
    } catch (_) {
      setState(() => _error = '알 수 없는 오류가 발생했습니다.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persona Setting'),
        actions: const <Widget>[AppMenuButton()],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  _userName == null || _userName!.isEmpty
                      ? 'AI 페르소나를 선택하세요'
                      : '${_userName!}님, AI 페르소나를 선택하세요',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ToggleButtons(
                  isSelected: <bool>[
                    _selectedId == 1,
                    _selectedId == 2,
                    _selectedId == 3,
                  ],
                  onPressed: _isLoading
                      ? null
                      : (int index) {
                          setState(() => _selectedId = index + 1);
                        },
                  children: const <Widget>[
                    Padding(padding: EdgeInsets.all(8), child: Text('1')),
                    Padding(padding: EdgeInsets.all(8), child: Text('2')),
                    Padding(padding: EdgeInsets.all(8), child: Text('3')),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '한 번 선택한 페르소나는 나중에 메뉴에서 다시 변경할 수 있습니다.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading || _selectedId == null ? null : _submitPersona,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('확인'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

