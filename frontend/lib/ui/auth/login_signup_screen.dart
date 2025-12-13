import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:justaday/state/auth_provider.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart'; // url_launcher import

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  Timer? _debounce;

  // 1. 개인정보 처리방침 동의 상태 변수 추가
  bool _isPrivacyPolicyAgreed = false;

  @override
  void initState() {
    super.initState();
    _userIdController.addListener(_onUserIdChanged);
    _passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _userIdController.removeListener(_onUserIdChanged);
    _passwordController.removeListener(_updateButtonState);
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onUserIdChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!_isLogin) {
        context.read<AuthProvider>().checkIdAvailability(
          _userIdController.text.trim(),
        );
      }
    });
    _updateButtonState();
  }

  void _updateButtonState() {
    setState(() {});
  }

  // 2. URL을 여는 함수 추가
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      // URL을 열 수 없을 때 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('링크를 열 수 없습니다: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    // 4. 회원가입 버튼 활성화 조건 수정
    final isButtonEnabled = _userIdController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        !auth.isLoading &&
        (_isLogin || _isPrivacyPolicyAgreed); // 로그인 모드가 아니면 동의해야 활성화

    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? '로그인' : '회원가입')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    controller: _userIdController,
                    decoration: InputDecoration(
                      labelText: '아이디',
                      errorText: _isLogin ? null : auth.idcheckError,
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) return '아이디를 입력해주세요.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: '비밀번호'),
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return '비밀번호를 입력해주세요.';
                      return null;
                    },
                  ),
                  if (!_isLogin) ...[
                    const SizedBox(height: 16),
                    // 3. 개인정보 처리방침 동의 UI 추가
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _isPrivacyPolicyAgreed,
                          onChanged: (bool? value) {
                            setState(() {
                              _isPrivacyPolicyAgreed = value ?? false;
                            });
                          },
                        ),
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: '개인정보 처리방침',
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {

                                    _launchURL('https://jahee24.github.io/justaday_Privacy/');
                                  },
                              ),
                              const TextSpan(text: '에 동의합니다.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        border: Border.all(color: Colors.orange.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              '회원가입 시 한 번 정한 아이디와 비밀번호는\n잃어버려도 찾을 수 없고 수정할 수도 없습니다.',
                              style: TextStyle(fontSize: 12, color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (auth.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        auth.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isButtonEnabled ? () => _handleSubmit(auth) : null,
                      child: auth.isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_isLogin ? '로그인' : '회원가입'),
                    ),
                  ),
                  TextButton(
                    onPressed: auth.isLoading ? null : () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _isPrivacyPolicyAgreed = false; // 모드 변경 시 동의 상태 초기화
                      });
                      context.read<AuthProvider>().clearError();
                    },
                    child: Text(_isLogin ? '계정이 없으신가요? 회원가입' : '이미 계정이 있으신가요? 로그인'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;

    // 회원가입 시 동의 여부 재확인
    if (!_isLogin && !_isPrivacyPolicyAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('개인정보 처리방침에 동의해주세요.')),
      );
      return;
    }

    final String userId = _userIdController.text.trim();
    final String password = _passwordController.text.trim();

    if (_isLogin) {
      await auth.login(userId: userId, password: password);
    } else {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('계정 정보를 확인해주세요'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('아이디: $userId'),
              const SizedBox(height: 4),
              Text('비밀번호: $password'),
              const SizedBox(height: 12),
              const Text(
                '한 번 설정한 아이디와 비밀번호는\n잃어버려도 찾거나 변경할 수 없습니다.',
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await auth.signup(userId: userId, password: password);
      }
    }
  }
}