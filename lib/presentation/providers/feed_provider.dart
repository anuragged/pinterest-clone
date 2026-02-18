import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pin.dart';
import '../../domain/usecases/get_feed_pins.dart';
import '../../domain/usecases/save_pin.dart';
import '../../domain/usecases/recommendation_engine.dart';
import '../../core/constants/api_constants.dart';
import '../../data/repositories/pin_repository_impl.dart';
import '../../data/sources/pexels_api_service.dart';
import '../../data/sources/local_cache_service.dart';
import '../../services/network_service.dart';

// ── Service Providers ──

final networkServiceProvider = Provider<NetworkService>((ref) {
  return NetworkService();
});

final localCacheServiceProvider = Provider<LocalCacheService>((ref) {
  return LocalCacheService();
});

final pexelsApiServiceProvider = Provider<PexelsApiService>((ref) {
  return PexelsApiService(ref.read(networkServiceProvider));
});

final pinRepositoryProvider = Provider<PinRepositoryImpl>((ref) {
  return PinRepositoryImpl(
    ref.read(pexelsApiServiceProvider),
    ref.read(localCacheServiceProvider),
  );
});

final getFeedPinsProvider = Provider<GetFeedPins>((ref) {
  return GetFeedPins(ref.read(pinRepositoryProvider));
});

final savePinUseCaseProvider = Provider<SavePin>((ref) {
  return SavePin(ref.read(pinRepositoryProvider));
});

final unsavePinUseCaseProvider = Provider<UnsavePin>((ref) {
  return UnsavePin(ref.read(pinRepositoryProvider));
});

final recordPinClickProvider = Provider<RecordPinClick>((ref) {
  return RecordPinClick(ref.read(pinRepositoryProvider));
});

// ── Feed State ──

class FeedState {
  final List<Pin> pins;
  final int currentPage;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final double scrollOffset;

  const FeedState({
    this.pins = const [],
    this.currentPage = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.scrollOffset = 0.0,
  });

  FeedState copyWith({
    List<Pin>? pins,
    int? currentPage,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    double? scrollOffset,
  }) {
    return FeedState(
      pins: pins ?? this.pins,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      scrollOffset: scrollOffset ?? this.scrollOffset,
    );
  }
}

// ── Feed Notifier ──

class FeedNotifier extends StateNotifier<FeedState> {
  final GetFeedPins _getFeedPins;
  final LocalCacheService _cacheService;

  FeedNotifier(this._getFeedPins, this._cacheService) : super(const FeedState());

  /// Initial feed load.
  Future<void> loadFeed() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final pins = await _getFeedPins(
        page: 1,
        perPage: ApiConstants.feedPageSize,
      );
      final ranked = RecommendationEngine.personalizeRanking(
        pins,
        _cacheService.userInterests,
      );
      state = state.copyWith(
        pins: ranked,
        currentPage: 1,
        isLoading: false,
        hasMore: pins.length >= ApiConstants.feedPageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load next page (infinite scroll).
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final pins = await _getFeedPins(
        page: nextPage,
        perPage: ApiConstants.feedPageSize,
      );
      final ranked = RecommendationEngine.personalizeRanking(
        pins,
        _cacheService.userInterests,
      );
      state = state.copyWith(
        pins: [...state.pins, ...ranked],
        currentPage: nextPage,
        isLoadingMore: false,
        hasMore: pins.length >= ApiConstants.feedPageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  /// Pull-to-refresh: reset feed to page 1.
  Future<void> refresh() async {
    state = state.copyWith(error: null);
    try {
      // Pick a random seed page for refresh to show different content
      final randomPage = math.Random().nextInt(20) + 1;
      final pins = await _getFeedPins(
        page: randomPage,
        perPage: ApiConstants.feedPageSize,
      );
      
      // Shuffle the pins for an even fresher feel
      final shuffled = List<Pin>.from(pins)..shuffle();

      final ranked = RecommendationEngine.personalizeRanking(
        shuffled,
        _cacheService.userInterests,
      );
      state = FeedState(
        pins: ranked,
        currentPage: randomPage,
        hasMore: pins.length >= ApiConstants.feedPageSize,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Save scroll position for restoration on back navigation.
  void saveScrollOffset(double offset) {
    state = state.copyWith(scrollOffset: offset);
  }

  /// Optimistic save: update pin in-place.
  void updatePin(Pin updatedPin) {
    final index = state.pins.indexWhere((p) => p.id == updatedPin.id);
    if (index != -1) {
      final newPins = List<Pin>.from(state.pins);
      newPins[index] = updatedPin;
      state = state.copyWith(pins: newPins);
    }
  }
}

// ── Feed Provider ──

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier(
    ref.read(getFeedPinsProvider),
    ref.read(localCacheServiceProvider),
  );
});
