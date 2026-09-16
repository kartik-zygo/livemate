import 'package:intl/intl.dart';

/// Display formatting. Money is always rupees with Indian digit grouping —
/// ₹15,000, ₹1,20,000 — never a plain thousands separator.
class Fmt {
  const Fmt._();

  static final NumberFormat _inr = NumberFormat.decimalPattern('en_IN');
  static final DateFormat _dayMonthYear = DateFormat('d MMM yyyy');
  static final DateFormat _dayMonth = DateFormat('d MMM');

  static String money(num? amount) {
    if (amount == null) return '—';
    return '₹${_inr.format(amount)}';
  }

  /// Compacts large amounts for tight spots: ₹15K, ₹1.2L.
  static String moneyCompact(num? amount) {
    if (amount == null) return '—';
    final v = amount.abs();
    if (v >= 10000000) {
      return '₹${_trim(amount / 10000000)}Cr';
    }
    if (v >= 100000) {
      return '₹${_trim(amount / 100000)}L';
    }
    if (v >= 1000) {
      return '₹${_trim(amount / 1000)}K';
    }
    return money(amount);
  }

  static String moneyRange(num? min, num? max) {
    if (min == null && max == null) return 'Any budget';
    if (min == null) return 'Up to ${money(max)}';
    if (max == null) return '${money(min)}+';
    if (min == max) return money(min);
    return '${money(min)} – ${money(max)}';
  }

  static String _trim(double v) {
    final s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  static String date(DateTime? value) =>
      value == null ? '—' : _dayMonthYear.format(value);

  static String shortDate(DateTime? value) =>
      value == null ? '—' : _dayMonth.format(value);

  /// "Available now" whenever [from] is null or already in the past — the rule
  /// the API expects the client to apply.
  static String availability(DateTime? from) {
    if (from == null || !from.isAfter(DateTime.now())) return 'Available now';
    return 'From ${_dayMonth.format(from)}';
  }

  /// Compact relative time for list rows: "just now", "4h ago", "3 Sep".
  static String relative(DateTime? value) {
    if (value == null) return '';
    final diff = DateTime.now().difference(value);
    if (diff.isNegative) return _dayMonth.format(value);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 365) return _dayMonth.format(value);
    return _dayMonthYear.format(value);
  }

  static String fileSize(int? bytes) {
    if (bytes == null) return '—';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String plural(int count, String one, String many) =>
      count == 1 ? '$count $one' : '$count $many';

  static String ageRange(int? min, int? max) {
    if (min == null && max == null) return 'Any age';
    if (min == null) return 'Up to $max';
    if (max == null) return '$min+';
    return '$min–$max yrs';
  }
}
