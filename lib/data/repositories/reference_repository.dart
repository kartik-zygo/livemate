import '../models/city_model.dart';
import '../models/legal_model.dart';
import '../models/tag_model.dart';
import '../providers/reference_api_provider.dart';

class ReferenceRepository {
  const ReferenceRepository(this._api);

  final ReferenceApiProvider _api;

  Future<List<CityModel>> cities() async {
    final rows = await _api.cities();
    final list = rows.map(CityModel.fromJson).toList()
      ..sort((a, b) {
        final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        return byName != 0 ? byName : a.state.compareTo(b.state);
      });
    return list;
  }

  Future<List<TagModel>> tags() async {
    final rows = await _api.tags();
    final list = rows.map(TagModel.fromJson).toList()
      ..sort((a, b) {
        final byCategory = a.category.index.compareTo(b.category.index);
        return byCategory != 0
            ? byCategory
            : a.sortOrder.compareTo(b.sortOrder);
      });
    return list;
  }

  Future<LegalInfo> legal() async => LegalInfo.fromJson(await _api.legal());
}
