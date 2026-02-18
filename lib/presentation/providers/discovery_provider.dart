import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pin.dart';
import 'feed_provider.dart';

class DiscoveryState {
  final List<Pin> ideasForYou;
  final List<Pin> todayInspiration;
  final List<Pin> featuredBoards;
  final List<Pin> creatorIdeas;
  final List<Pin> spotlight;
  final Map<String, List<Pin>> popularTopics;
  final bool isLoading;

  DiscoveryState({
    this.ideasForYou = const [],
    this.todayInspiration = const [],
    this.featuredBoards = const [],
    this.creatorIdeas = const [],
    this.spotlight = const [],
    this.popularTopics = const {},
    this.isLoading = false,
  });

  DiscoveryState copyWith({
    List<Pin>? ideasForYou,
    List<Pin>? todayInspiration,
    List<Pin>? featuredBoards,
    List<Pin>? creatorIdeas,
    List<Pin>? spotlight,
    Map<String, List<Pin>>? popularTopics,
    bool? isLoading,
  }) {
    return DiscoveryState(
      ideasForYou: ideasForYou ?? this.ideasForYou,
      todayInspiration: todayInspiration ?? this.todayInspiration,
      featuredBoards: featuredBoards ?? this.featuredBoards,
      creatorIdeas: creatorIdeas ?? this.creatorIdeas,
      spotlight: spotlight ?? this.spotlight,
      popularTopics: popularTopics ?? this.popularTopics,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DiscoveryNotifier extends StateNotifier<DiscoveryState> {
  final Ref _ref;

  DiscoveryNotifier(this._ref) : super(DiscoveryState());

  Future<void> loadDiscovery() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);

    final api = _ref.read(pexelsApiServiceProvider);

    try {
      // Fetch ideas for you
      final ideas = await api.searchPhotos(query: 'interior design outfit cooking art travel diy', perPage: 6, page: 1);
      
      // Fetch today inspiration
      final inspiration = await api.getCuratedPhotos(perPage: 7, page: 2);
      
      // Fetch featured boards
      final boards = await api.searchPhotos(query: 'modern home aesthetic', perPage: 4, page: 1);
      
      // Fetch creator ideas
      final creators = await api.searchPhotos(query: 'portrait', perPage: 5, page: 1);
      
      // Fetch spotlight
      final spotlightResp = await api.searchPhotos(query: 'lifestyle wellness', perPage: 1, page: 1);
      
      // Fetch popular topics
      final topics = <String, List<Pin>>{};
      final topicQueries = ['Holi', 'Drawing', 'Cake', 'Portrait'];
      for (final topic in topicQueries) {
        topics[topic] = await api.searchPhotos(query: topic, perPage: 4, page: 1);
      }

      state = state.copyWith(
        ideasForYou: ideas,
        todayInspiration: inspiration,
        featuredBoards: boards,
        creatorIdeas: creators,
        spotlight: spotlightResp,
        popularTopics: topics,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final discoveryProvider = StateNotifierProvider<DiscoveryNotifier, DiscoveryState>((ref) {
  return DiscoveryNotifier(ref);
});
