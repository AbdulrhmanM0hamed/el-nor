/// A centralized validator utility that provides common input
/// validation rules used across the app. All methods return an
/// Arabic error message when validation fails, otherwise `null`.
///
/// Having a single source of truth for validation improves
/// consistency and security and keeps UI widgets clean.
class InputValidator {
  InputValidator._();

  // ---------------------------- Text -----------------------------
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال الاسم';
    }
    if (value.trim().length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }
    return null;
  }

  // ---------------------------- Email ----------------------------
  static final RegExp _emailRegex =
      RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'الرجاء إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  // ---------------------------- Phone ----------------------------
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    // Accepts numbers with optional leading + and between 7-15 digits
    final RegExp regex = RegExp(r'^\+?\d{7,15}$');
    if (!regex.hasMatch(value.trim())) {
      return 'الرجاء إدخال رقم هاتف صحيح';
    }
    return null;
  }

  // ----------------------------- Age -----------------------------
  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال العمر';
    }
    final int? age = int.tryParse(value.trim());
    if (age == null) {
      return 'الرجاء إدخال رقم صحيح';
    }
    if (age < 3 || age > 100) {
      return 'الرجاء إدخال عمر بين 3 و 100';
    }
    return null;
  }

  // -------------------------- Password ---------------------------
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    // Require: upper, lower, digit, special
    final bool hasUpper = value.contains(RegExp(r'[A-Z]'));
    final bool hasLower = value.contains(RegExp(r'[a-z]'));
    final bool hasDigit = value.contains(RegExp(r'\d'));
    final bool hasSpecial = value.contains(RegExp(r'[!@#\$&*~%^]'));

    if (!hasUpper || !hasLower || !hasDigit || !hasSpecial) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير وصغير، رقم، ورمز خاص';
    }

    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'الرجاء تأكيد كلمة المرور';
    }
    if (value != original) {
      return 'كلمات المرور غير متطابقة';
    }
    return null;
  }
}
