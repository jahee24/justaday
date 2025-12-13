import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:justaday/core/navigation/navigation_service.dart';
import 'package:justaday/data/api/dio_client.dart';
import 'package:justaday/data/user/user_service.dart';
import 'package:justaday/ui/common/app_menu_button.dart';

class NameSettingScreen extends StatefulWidget {
  const NameSettingScreen({super.key});

  @override
  State<NameSettingScreen> createState() => _NameSettingScreenState();
}

class _NameSettingScreenState extends State<NameSettingScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = true; // 초기 상태를 로딩으로 변경
  String? _error;
  String? _savedName;

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final String? name = await UserService.instance.getUserName();
    if (mounted) {
      setState(() {
        if (name != null && name.isNotEmpty) {
          _savedName = name;
        }
        _isLoading = false;
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
    try {
      await DioClient.dio.post<dynamic>(
        '/api/v1/user/name',
        data: <String, dynamic>{'name': name},
      );
      await UserService.instance.saveUserName(name);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름이 저장되었습니다.')),
      );
      await NavigationService.navigateToRecord(replace: true);

    } on DioException catch (e) {
      final String? errorMessage = e.response?.data is Map<String, dynamic>
          ? e.response?.data['message'] as String?
          : null;
      setState(() => _error = errorMessage ?? e.message ?? '네트워크 오류가 발생했습니다.');
    } catch (e) {
      setState(() => _error = '이름 저장 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이름 설정'),
        actions: const [AppMenuButton()],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _savedName != null
                      ? _buildNameDisplay()
                      : _buildNameInput(),
                ),
              ),
            ),
    );
  }

  // 이름이 이미 설정된 경우 보여줄 위젯
  Widget _buildNameDisplay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('등록된 이름', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Text(_savedName!, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 20),
        const Text(
          '이름은 한 번만 설정할 수 있습니다.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // 이름을 설정해야 하는 경우 보여줄 위젯
  Widget _buildNameInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text('이름을 입력해주세요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            onPressed: _isLoading ? null : _saveName,
            child: const Text('저장'),
          ),
        ),
      ],
    );
  }
}
