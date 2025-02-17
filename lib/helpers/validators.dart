import 'date_helper.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    // if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$').hasMatch(value)) {
    //   return 'Password must include an uppercase letter, a number, and a special character';
    // }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name cannot be empty';
    if (value.length < 3) return 'Name must be at least 3 characters long';
    return null;
  }

  static String? validateDOB(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a valid date of birth';
    }

    final dateOfBirth = DateTime.tryParse(value);
    if (dateOfBirth == null) {
      return 'Invalid date format';
    }

    if (!DateHelper.isValidDOB(dateOfBirth)) {
      return 'You must be at least 18 years old';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your phone number';
    if (!RegExp(r'^\+\d{10,15}$').hasMatch(value)) {
      return 'Please enter a valid phone number with country code';
    }
    return null;
  }
}
