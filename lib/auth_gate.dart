import 'package:chat_app/chat/presentation/pages/categores_page.dart';
import 'package:chat_app/chat/presentation/pages/login_page.dart';
import 'package:chat_app/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      final canCheck =
          await auth.canCheckBiometrics || await auth.isDeviceSupported();

      if (!canCheck) {
        setState(() {
          _isAuthenticated = true;
          _isChecking = false;
        });
        return;
      }

      final result = await auth.authenticate(
        localizedReason: 'أكد هويتك لفتح التطبيق',
      );

      setState(() {
        _isAuthenticated = result;
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _isAuthenticated = false;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppUtils.instance.getUser();
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isAuthenticated) {
      return user != null && user.username != null
          ? const CategoresPage()
          : const AuthPage(); // شاشتك الرئيسية
    }

    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            setState(() => _isChecking = true);
            _authenticate();
          },
          child: const Text('حاول تاني'),
        ),
      ),
    );
  }
}
