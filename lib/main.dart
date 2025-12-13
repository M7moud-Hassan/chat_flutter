import 'package:chat_app/chat/presentation/pages/home.page.dart';
import 'package:chat_app/core/theme/theme.dart';
import 'package:chat_app/core/utils/app_utils.dart';
import 'package:chat_app/core/utils/shared_pref.dart';
import 'package:chat_app/core/utils/storage_paths.dart';
import 'package:chat_app/injections/injections_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await init();
  await SharedPref.init();

  await DeviceStorage.init();

  ErrorWidget.builder = (details) => CustomErrorWidget(details: details);
  return runApp(
    const ProviderScope(
      child: WhatsApp(),
    ),
  );
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..dismissOnTap = false
    ..indicatorColor = Colors.white
    ..maskColor = Colors.black.withOpacity(0.5)
    ..backgroundColor = Colors.transparent
    ..boxShadow = <BoxShadow>[]
    ..maskType = EasyLoadingMaskType.clear
    ..indicatorSize = 50
    ..contentPadding = EdgeInsets.zero
    ..textColor = Colors.white
    ..progressColor = Colors.white;
}

class WhatsApp extends ConsumerWidget {
  const WhatsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppUtils.instance.setUpNotifications(context, ref);
    configLoading();

    return MaterialApp(
      builder: EasyLoading.init(),
      title: "مداولة",
      initialRoute: '/',
      theme: ref.read(lightThemeProvider),
      darkTheme: ref.read(darkThemeProvider),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Directionality(
          child: HomePage(user: AppUtils.user!),
          textDirection: TextDirection.rtl),
      // home: StreamBuilder<auth.User?>(
      //   stream: ref.read(authRepositoryProvider).auth.authStateChanges(),
      //   builder: (BuildContext context, snapshot) {
      //     if (!snapshot.hasData) {
      //       return const WelcomePage();
      //     }

      //     final user = getCurrentUser();
      //     if (user == null) {
      //       return const WelcomePage();
      //     }

      //     return HomePage(user: user);
      //   },
      // ),
    );
  }
}

class CustomErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;

  const CustomErrorWidget({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;
    SharedPref.instance
        .setDouble('keyboardHeight', MediaQuery.of(context).viewInsets.bottom);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 25,
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(150),
                  color: colorTheme.appBarColor,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red[400],
                  size: 50,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorTheme.appBarColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                      ),
                      child: ListView(
                        children: [
                          const SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            'OOPS!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.red[400],
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            details.toString(),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: colorTheme.blueColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
