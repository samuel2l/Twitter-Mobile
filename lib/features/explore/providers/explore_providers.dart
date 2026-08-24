import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client_provider.dart';
import '../models/explore_feed_state.dart';
import '../repository/explore_repository.dart';
import '../service/explore_service.dart';
import 'explore_feed_controller.dart';

final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  return ExploreRepository(ref.watch(apiClientProvider));
});

final exploreServiceProvider = Provider<ExploreService>((ref) {
  return ExploreService(ref.watch(exploreRepositoryProvider));
});

final exploreFeedControllerProvider =
    AsyncNotifierProvider<ExploreFeedController, ExploreFeedState>(
  ExploreFeedController.new,
);
