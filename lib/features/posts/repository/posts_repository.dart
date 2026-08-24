import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../utils/constants/api_constants.dart';
import '../models/create_post_input.dart';

class PostsRepository {
  const PostsRepository(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> create(CreatePostInput input) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.posts,
      data: input.toJson(),
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.postById(id),
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getReplies(String id, {int limit = 50}) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.postReplies(id),
      queryParameters: {'limit': limit},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getByUser(String userId, {int limit = 20}) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.postsByUser(userId),
      queryParameters: {'limit': limit},
    );
    return response.data ?? {};
  }

  Future<UploadedMedia> uploadMedia({
    required String filePath,
    required String fileName,
    String? mimeType,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    final response = await _client.postMultipart<Map<String, dynamic>>(
      ApiConstants.mediaUpload,
      data: formData,
    );
    return UploadedMedia.fromJson(response.data ?? {});
  }
}
