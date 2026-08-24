import '../../../core/errors/app_exception.dart';
import '../../../core/models/post.dart';
import '../models/create_post_input.dart';
import '../repository/posts_repository.dart';

class PostsService {
  const PostsService(this._repository);

  final PostsRepository _repository;

  Future<Post> create(CreatePostInput input) async {
    final data = await _repository.create(input);
    try {
      return Post.fromJson(data);
    } on FormatException catch (error) {
      throw ParseException('Invalid create post response: $error');
    }
  }

  Future<Post> getById(String id) async {
    final data = await _repository.getById(id);
    try {
      return Post.fromJson(data);
    } on FormatException catch (error) {
      throw ParseException('Invalid post response: $error');
    }
  }

  Future<List<Post>> getReplies(String id) async {
    final data = await _repository.getReplies(id);
    return _parseItems(data);
  }

  Future<List<Post>> getByUser(String userId) async {
    final data = await _repository.getByUser(userId);
    return _parseItems(data);
  }

  Future<UploadedMedia> uploadMedia({
    required String filePath,
    required String fileName,
    String? mimeType,
  }) {
    return _repository.uploadMedia(
      filePath: filePath,
      fileName: fileName,
      mimeType: mimeType,
    );
  }

  List<Post> _parseItems(Map<String, dynamic> data) {
    final itemsJson = data['items'];
    if (itemsJson is! List) return const [];
    return itemsJson
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();
  }
}
