class Validator {
  final bool Function(String? value)? validation;
  final String desValidation;
  Validator({required this.validation, required this.desValidation});

  bool validate(String? input) {
    if (validation != null) {
      return validation!(input);
    }
    return false;
  }

  static bool validateEmail(String value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return !emailRegex.hasMatch(value);
  }

  static bool validatePassword(String value) {
    final passwordRegex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}$');
    return !passwordRegex.hasMatch(value);
  }

  static bool validateUsername(String value) {
    final usernameRegex = RegExp(r'^[a-zA-Z0-9._]{3,20}$');
    return !usernameRegex.hasMatch(value);
  }
}
