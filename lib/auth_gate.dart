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

    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: onSurface.withValues(alpha: 0.5)),
              const SizedBox(height: 20),
              Text(
                'محتاجين نتأكد من هويتك قبل فتح التطبيق',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: onSurface.withValues(alpha: 0.75)),
              ),
              const SizedBox(height: 8),
              Text(
                'أكد ببصمتك أو رمز جهازك',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: onSurface.withValues(alpha: 0.4)),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _isChecking = true);
                  _authenticate();
                },
                icon: const Icon(Icons.fingerprint),
                label: const Text('جرب مره اخري'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
