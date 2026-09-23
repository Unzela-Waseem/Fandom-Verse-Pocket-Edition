abstract final class InputValidators {
  static String? required(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$label is required.';
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value, label: 'Email');
    if (requiredError != null) return requiredError;
    final pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return pattern.hasMatch(value!.trim())
        ? null
        : 'Enter a valid email address.';
  }

  static String? password(String? value) {
    final requiredError = required(value, label: 'Password');
    if (requiredError != null) return requiredError;
    if (value!.length < 8) return 'Use at least 8 characters.';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Add an uppercase letter.';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Add a number.';
    return null;
  }
}
