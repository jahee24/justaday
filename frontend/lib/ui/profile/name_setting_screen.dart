import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/core/navigation/navigation_service.dart';
import 'package:my_first_app/data/api/dio_client.dart';
import 'package:my_first_app/data/user/user_service.dart';

class NameSettingScreen extends StatefulWidget {
  const NameSettingScreen({super.key});

  @override
  State<NameSettingScreen> createState() => _NameSettingScreenState();
}

class _NameSettingScreenState extends State<NameSettingScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _isNameLocked = false;

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final String? name = await UserService.instance.getUserName();
    if (!mounted) return;
    if (name != null && name.isNotEmpty) {
      setState(() {
        _controller.text = name;
        _isNameLocked = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final String name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '이름을 입력해주세요.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final Dio dio = DioClient.dio;
    try {
      await dio.post<dynamic>(
        'https://divine-tenderness-production-9284.up.railway.app/api/v1/user/name',
        data: <String, dynamic>{'name': name},
      );
      await UserService.instance.saveUserName(name);
      if (!mounted) return;
      setState(() => _isNameLocked = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름이 저장되었습니다.')),
      );
      await NavigationService.navigateToRecord();
    } on DioException catch (e) {
      final String? errorMessage = e.response?.data is Map<String, dynamic>
          ? e.response?.data['message'] as String?
          : null;
      setState(() => _error = errorMessage ?? e.message ?? '네트워크 오류가 발생했습니다.');
    } catch (e) {
      setState(() => _error = '이름 저장 중 오류가 발생했습니다: ${e.toString()}');
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
        title: const Text('이름 설정'),
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
                  _isNameLocked ? '등록된 이름' : '이름을 입력해주세요',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '이름은 한 번 설정하면 변경할 수 없습니다.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: '이름',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: _isNameLocked,
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
                    onPressed: _isLoading || _isNameLocked ? null : _saveName,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('저장'),
                  ),
                ),
                if (_isNameLocked)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      '이미 이름이 설정되어 있습니다.',
                      style: TextStyle(color: Colors.green),
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


