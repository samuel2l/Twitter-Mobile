import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/post.dart';
import '../../../core/network/api_client_provider.dart';
import '../models/create_post_input.dart';
import '../repository/posts_repository.dart';
import '../service/posts_service.dart';

final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  return PostsRepository(ref.watch(apiClientProvider));
});

final postsServiceProvider = Provider<PostsService>((ref) {
  return PostsService(ref.watch(postsRepositoryProvider));
});

final postDetailProvider =
    FutureProvider.autoDispose.family<Post, String>((ref, postId) {
  return ref.watch(postsServiceProvider).getById(postId);
});

final postRepliesProvider =
    FutureProvider.autoDispose.family<List<Post>, String>((ref, postId) {
  return ref.watch(postsServiceProvider).getReplies(postId);
});

final userPostsProvider =
    FutureProvider.autoDispose.family<List<Post>, String>((ref, userId) {
  return ref.watch(postsServiceProvider).getByUser(userId);
});

final composeControllerProvider =
    AsyncNotifierProvider<ComposeController, void>(ComposeController.new);

class ComposeController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Post> submit(CreatePostInput input) async {
    state = const AsyncLoading();
    late final Post created;
    state = await AsyncValue.guard(() async {
      created = await ref.read(postsServiceProvider).create(input);
    });
    if (state.hasError) {
      throw state.error!;
    }
    return created;
  }

  Future<UploadedMedia> upload({
    required String filePath,
    required String fileName,
    String? mimeType,
  }) {
    return ref.read(postsServiceProvider).uploadMedia(
          filePath: filePath,
          fileName: fileName,
          mimeType: mimeType,
        );
  }
}
