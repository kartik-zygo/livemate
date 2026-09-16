import '../models/finder_post_model.dart';
import '../providers/finder_post_api_provider.dart';

class FinderPostRepository {
  const FinderPostRepository(this._api);

  final FinderPostApiProvider _api;

  Future<FinderPostModel> create(FinderPostPayload payload) async =>
      FinderPostModel.fromJson(await _api.create(payload.toJson()));

  Future<FinderPostModel> byId(String id) async =>
      FinderPostModel.fromJson(await _api.byId(id));

  Future<List<FinderPostModel>> mine() async =>
      (await _api.mine()).map(FinderPostModel.fromJson).toList();

  Future<FinderPostModel> update(String id, FinderPostPayload payload) async =>
      FinderPostModel.fromJson(await _api.update(id, payload.toJson()));

  Future<void> remove(String id) => _api.remove(id);
}
