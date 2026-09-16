import '../../core/utils/json_utils.dart';

/// City names repeat across states (Udaipur, Aurangabad, Bilaspur…), so the UI
/// must always render [displayName], never [name] alone.
class CityModel {
  const CityModel({
    required this.id,
    required this.name,
    required this.state,
    required this.slug,
  });

  final String id;
  final String name;
  final String state;
  final String slug;

  String get displayName => state.isEmpty ? name : '$name, $state';

  /// Lower-cased once at construction time so the in-memory typeahead over 652
  /// rows does not re-case on every keystroke.
  String get searchName => name.toLowerCase();
  String get searchState => state.toLowerCase();

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
    id: asString(json['id']),
    name: asString(json['name']),
    state: asString(json['state']),
    slug: asString(json['slug']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'state': state,
    'slug': slug,
  };

  @override
  bool operator ==(Object other) => other is CityModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
