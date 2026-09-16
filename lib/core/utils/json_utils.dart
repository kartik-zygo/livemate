// Defensive JSON coercion. The API is well-behaved, but a single unexpected
// null on a list screen should not take the whole screen down.

String asString(Object? v, [String fallback = '']) =>
    v is String ? v : (v == null ? fallback : v.toString());

String? asStringOrNull(Object? v) {
  if (v is String) return v.isEmpty ? null : v;
  return v?.toString();
}

int asInt(Object? v, [int fallback = 0]) => switch (v) {
  int() => v,
  double() => v.round(),
  String() => int.tryParse(v) ?? double.tryParse(v)?.round() ?? fallback,
  _ => fallback,
};

int? asIntOrNull(Object? v) => v == null ? null : asInt(v);

bool asBool(Object? v, [bool fallback = false]) => switch (v) {
  bool() => v,
  String() => v.toLowerCase() == 'true',
  int() => v != 0,
  _ => fallback,
};

DateTime? asDate(Object? v) {
  if (v is DateTime) return v;
  if (v is! String || v.isEmpty) return null;
  return DateTime.tryParse(v)?.toLocal();
}

Map<String, dynamic> asMap(Object? v) =>
    v is Map ? Map<String, dynamic>.from(v) : const <String, dynamic>{};

Map<String, dynamic>? asMapOrNull(Object? v) =>
    v is Map ? Map<String, dynamic>.from(v) : null;

List<Map<String, dynamic>> asMapList(Object? v) => v is List
    ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : const <Map<String, dynamic>>[];

List<String> asStringList(Object? v) => v is List
    ? v.whereType<String>().toList(growable: false)
    : const <String>[];

/// Drops null values so PATCH bodies only carry fields the user actually
/// touched — the API treats every field as optional.
Map<String, dynamic> pruneNulls(Map<String, dynamic> map) {
  final out = <String, dynamic>{};
  map.forEach((k, v) {
    if (v != null) out[k] = v;
  });
  return out;
}
