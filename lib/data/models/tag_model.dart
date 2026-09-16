import '../../core/utils/json_utils.dart';
import 'enums.dart';

class TagModel {
  const TagModel({
    required this.id,
    required this.category,
    required this.key,
    required this.label,
    required this.sortOrder,
  });

  final String id;
  final TagCategory category;
  final String key;
  final String label;
  final int sortOrder;

  factory TagModel.fromJson(Map<String, dynamic> json) => TagModel(
    id: asString(json['id']),
    category: TagCategory.fromWire(json['category']),
    key: asString(json['key']),
    label: asString(json['label']),
    sortOrder: asInt(json['sortOrder']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.wire,
    'key': key,
    'label': label,
    'sortOrder': sortOrder,
  };

  @override
  bool operator ==(Object other) => other is TagModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
