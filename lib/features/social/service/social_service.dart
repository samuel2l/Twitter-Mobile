import '../models/social_user.dart';
import '../repository/social_repository.dart';

class SocialService {
  const SocialService(this._repository);

  final SocialRepository _repository;

  Future<void> follow(String userId) => _repository.follow(userId);

  Future<void> unfollow(String userId) => _repository.unfollow(userId);

  Future<bool> isFollowing(String userId) async {
    final data = await _repository.followStatus(userId);
    return data['following'] as bool? ?? false;
  }

  Future<SocialUser> getUser(String userId) async {
    final data = await _repository.getUser(userId);
    return SocialUser.fromJson(data);
  }

  Future<List<SocialUser>> getFollowers(String userId) async {
    final data = await _repository.getFollowers(userId);
    return _parseUsers(data);
  }

  Future<List<SocialUser>> getFollowing(String userId) async {
    final data = await _repository.getFollowing(userId);
    return _parseUsers(data);
  }

  List<SocialUser> _parseUsers(Map<String, dynamic> data) {
    final items = data['items'];
    if (items is! List) return const [];
    return items.whereType<Map<String, dynamic>>().map(SocialUser.fromJson).toList();
  }
}
