import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/finder_post_model.dart';
import '../../../data/repositories/finder_post_repository.dart';

class FinderPostDetailController extends GetxController {
  FinderPostDetailController(this._repo, this._auth);

  final FinderPostRepository _repo;
  final AuthService _auth;

  final Rxn<FinderPostModel> post = Rxn<FinderPostModel>();
  final Rx<ViewStatus> status = ViewStatus.idle.obs;
  final RxnString error = RxnString();

  late final String postId;

  bool get isOwner => post.value != null && post.value!.ownerId == _auth.userId;

  @override
  void onInit() {
    super.onInit();
    postId = Get.arguments is String ? Get.arguments as String : '';
    load();
  }

  Future<void> load() async {
    if (postId.isEmpty) {
      error.value = 'That post could not be opened.';
      status.value = ViewStatus.error;
      return;
    }

    status.value = ViewStatus.loading;
    error.value = null;
    try {
      post.value = await _repo.byId(postId);
      status.value = ViewStatus.success;
    } on ApiException catch (e) {
      error.value = e.message;
      status.value = ViewStatus.error;
    }
  }

  Future<void> reload() => load();

  Future<void> deletePost() async {
    final confirmed = await AppFeedback.confirm(
      title: 'Delete this post?',
      message: 'It will stop appearing in searches immediately.',
      confirmLabel: 'Delete',
      destructive: true,
      icon: Icons.delete_forever_rounded,
    );
    if (!confirmed) return;

    try {
      await _repo.remove(postId);
      AppFeedback.success('Post deleted.');
      Get.back<bool>(result: true);
    } on ApiException catch (e) {
      AppFeedback.error(e.message);
    }
  }
}
