import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static bool enableSuperUser = false;
  final SharedPreferences sharedPreferences;
  AppConfig({required this.sharedPreferences}) {}

  Map<String, dynamic> toJson() => {'enableSuperUser': enableSuperUser};

  void updateConfig() {
    sharedPreferences.setString('config', json.encode(toJson()));
  }

  void fromJson(Map<String, dynamic> json) {
    enableSuperUser = json['enableSuperUser'];
  }

  void loadConfig() {
    if (sharedPreferences.containsKey('config')) {
      final json = jsonDecode(sharedPreferences.getString('config') ?? '');
      fromJson(json);
    }
  }
}
