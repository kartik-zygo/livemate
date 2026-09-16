/// Form validation. Every length bound here mirrors a server constraint, so a
/// user finds out before the round trip rather than after it.
class Validators {
  const Validators._();

  static final RegExp _email = RegExp(
    r"^[\w.!#$%&'*+/=?^`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
  );
  static final RegExp _phone = RegExp(r'^\+?[0-9\s-]{7,20}$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your email';
    if (!_email.hasMatch(v)) return 'That does not look like an email address';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Enter a password';
    if (v.length < 6) return 'Use at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return 'Re-enter your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your name';
    if (v.length < 2) return 'That name looks too short';
    if (v.length > 80) return 'Keep it under 80 characters';
    return null;
  }

  /// Optional — an empty phone is valid, a malformed one is not.
  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (v.length > 20) return 'Keep it under 20 characters';
    if (!_phone.hasMatch(v)) return 'Enter a valid phone number';
    return null;
  }

  static String? bio(String? value) {
    final v = value?.trim() ?? '';
    if (v.length > 500) return 'Keep your bio under 500 characters';
    return null;
  }

  static String? occupation(String? value) {
    final v = value?.trim() ?? '';
    if (v.length > 80) return 'Keep it under 80 characters';
    return null;
  }

  static String? listingTitle(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Give your listing a title';
    if (v.length < 3) return 'At least 3 characters';
    if (v.length > 120) return 'Keep it under 120 characters';
    return null;
  }

  static String? listingDescription(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Describe the place';
    if (v.length < 10) return 'At least 10 characters';
    if (v.length > 2000) return 'Keep it under 2000 characters';
    return null;
  }

  static String? budget(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter a monthly rent';
    final n = int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), ''));
    if (n == null) return 'Numbers only';
    if (n < 0) return 'That cannot be negative';
    if (n > 100000000) return 'That looks too high';
    return null;
  }

  /// Optional numeric field with an inclusive range.
  static String? optionalRange(
    String? value, {
    required int min,
    required int max,
    String unit = 'value',
  }) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    final n = int.tryParse(v);
    if (n == null) return 'Numbers only';
    if (n < min || n > max) return 'Enter a $unit between $min and $max';
    return null;
  }

  static String? enquiryMessage(String? value) {
    final v = value?.trim() ?? '';
    if (v.length > 500) return 'Keep your message under 500 characters';
    return null;
  }

  static String? note(String? value) {
    final v = value?.trim() ?? '';
    if (v.length > 500) return 'Keep your note under 500 characters';
    return null;
  }

  /// Returns null when the range is coherent, or the reason it is not.
  static String? budgetRange(int? min, int? max) {
    if (min == null || max == null) return 'Set a budget range';
    if (min < 0 || max < 0) return 'Budget cannot be negative';
    if (min > max) return 'The minimum cannot exceed the maximum';
    return null;
  }

  static String? ageRange(int? min, int? max) {
    if (min != null && min < 18) return 'Minimum age is 18';
    if (max != null && max > 100) return 'Maximum age is 100';
    if (min != null && max != null && min > max) {
      return 'The minimum age cannot exceed the maximum';
    }
    return null;
  }
}
