import 'package:chat_app/chat/domain/entities/login_entity.dart';
import 'package:chat_app/chat/presentation/bloc/login/login_bloc.dart';
import 'package:chat_app/chat/presentation/pages/categores_page.dart';
import 'package:chat_app/core/utils/app_utils.dart';
import 'package:chat_app/injections/injections_main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  late TabController _tabController;

  final TextEditingController _loginUsernameController =
      TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  final TextEditingController _registerUsernameController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();
  final TextEditingController _registerConfirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    // Clear form when switching tabs
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    _registerUsernameController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  void _submitLogin(BuildContext contextt) async {
    if (_loginFormKey.currentState!.validate()) {
      final username = _loginUsernameController.text.trim();
      final password = _loginPasswordController.text;
      final deviceId = await AppUtils.getDeviceId();
      contextt.read<LoginBloc>().add(SendLoginEvent(
          username: LoginEntity(
              username: username,
              password: password,
              deviceId: deviceId,
              type: 'l')));
    }
  }

  void _submitRegister(BuildContext contextt) async {
    if (_registerFormKey.currentState!.validate()) {
      final username = _registerUsernameController.text.trim();
      final password = _registerPasswordController.text;

      final deviceId = await AppUtils.getDeviceId();
      contextt.read<LoginBloc>().add(SendLoginEvent(
          username: LoginEntity(
              username: username,
              password: password,
              deviceId: deviceId,
              type: 'r')));
      // _tabController.animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LoginBloc>(),
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          if (state is DoneLoginState) {
            WidgetsBinding.instance.addPostFrameCallback((callback) {
              AppUtils.goAndReplace(const CategoresPage());
            });
          }
          return Scaffold(
            appBar: AppBar(
              title: Text('Authentication'.tr()),
              centerTitle: true,
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(icon: Icon(Icons.login), text: 'Login'.tr()),
                  Tab(icon: Icon(Icons.person_add), text: 'Register'.tr()),
                ],
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                // LOGIN TAB
                _buildLoginForm(context),

                // REGISTER TAB
                _buildRegisterForm(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginForm(contextt) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _loginFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                'Welcome Back'.tr(),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Please sign in to your account'.tr(),
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _loginUsernameController,
                decoration: InputDecoration(
                  labelText: 'Username'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 15,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username is required'.tr();
                  }
                  if (value.trim().length < 3) {
                    return 'Username must be at least 3 characters'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _loginPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 15,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required'.tr();
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  _submitLogin(contextt);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Sign In'.tr(),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?".tr()),
                  TextButton(
                    onPressed: () {
                      _tabController.animateTo(1);
                    },
                    child: Text('Sign Up'.tr()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm(contextt) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _registerFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                'Create Account'.tr(),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Sign up to get started'.tr(),
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _registerUsernameController,
                decoration: InputDecoration(
                  labelText: 'Username'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 15,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username is required'.tr();
                  }
                  if (value.trim().length < 3) {
                    return 'Username must be at least 3 characters'.tr();
                  }
                  // Check for spaces
                  if (value.contains(' ')) {
                    return 'Username cannot contain spaces'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _registerPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'Password'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 15,
                    ),
                    helperText: 'Minimum 6 characters'.tr()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required'.tr();
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _registerConfirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.lock_reset),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 15,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password'.tr();
                  }
                  if (value != _registerPasswordController.text) {
                    return 'Passwords do not match'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  _submitRegister(contextt);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Create Account'.tr(),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?".tr()),
                  TextButton(
                    onPressed: () {
                      _tabController.animateTo(0);
                    },
                    child: Text('Sign In'.tr()),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              Text(
                'By signing up, you agree to our Terms of Service and Privacy Policy'
                    .tr(),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
