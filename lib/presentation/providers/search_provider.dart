import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pin.dart';
import '../../domain/usecases/search_pins.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../core/constants/api_constants.dart';
import 'feed_provider.dart';

// ── Search Repository Provider ──

final searchRepositoryProvider = Provider<SearchRepositoryImpl>((ref) {
  return SearchRepositoryImpl(
    ref.read(pexelsApiServiceProvider),
    ref.read(localCacheServiceProvider),
  );
});

// ── Use Case Providers ──

final searchPinsUseCaseProvider = Provider<SearchPins>((ref) {
  return SearchPins(ref.read(searchRepositoryProvider));
});

final searchSuggestionsUseCaseProvider = Provider<GetSearchSuggestions>((ref) {
  return GetSearchSuggestions(ref.read(searchRepositoryProvider));
});

final searchHistoryUseCaseProvider = Provider<ManageSearchHistory>((ref) {
  return ManageSearchHistory(ref.read(searchRepositoryProvider));
});

// ── Search State ──

class SearchState {
  final String query;
  final List<Pin> results;
  final List<String> suggestions;
  final List<String> history;
  final List<String> trending;
  final int currentPage;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final bool isSearching; // Whether the search bar is actively focused
  final String? error;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.suggestions = const [],
    this.history = const [],
    this.trending = const [],
    this.currentPage = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.isSearching = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<Pin>? results,
    List<String>? suggestions,
    List<String>? history,
    List<String>? trending,
    int? currentPage,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    bool? isSearching,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      suggestions: suggestions ?? this.suggestions,
      history: history ?? this.history,
      trending: trending ?? this.trending,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      isSearching: isSearching ?? this.isSearching,
      error: error,
    );
  }
}

// ── Search Notifier ──

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref _ref;

  SearchNotifier(this._ref) : super(const SearchState());

  /// Initialize with trending searches and history.
  Future<void> initialize() async {
    final historyUc = _ref.read(searchHistoryUseCaseProvider);
    final repo = _ref.read(searchRepositoryProvider);
    final trending = await repo.getTrendingSearches();
    state = state.copyWith(
      history: historyUc.getHistory(),
      trending: trending,
    );
  }

  /// Update query and fetch instant suggestions.
  Future<void> updateQuery(String query) async {
    state = state.copyWith(query: query);
    if (query.isEmpty) {
      state = state.copyWith(suggestions: []);
      return;
    }
    final suggestionsUc = _ref.read(searchSuggestionsUseCaseProvider);
    final suggestions = await suggestionsUc(query);
    if (state.query == query) {
      state = state.copyWith(suggestions: suggestions);
    }
  }

  /// Execute search.
  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    // Save to history
    final historyUc = _ref.read(searchHistoryUseCaseProvider);
    historyUc.addToHistory(query);

    state = state.copyWith(
      query: query,
      isLoading: true,
      isSearching: false,
      results: [],
      error: null,
    );

    try {
      final searchUc = _ref.read(searchPinsUseCaseProvider);
      final results = await searchUc(
        query: query,
        page: 1,
        perPage: ApiConstants.searchPageSize,
      );
      state = state.copyWith(
        results: results,
        currentPage: 1,
        isLoading: false,
        hasMore: results.length >= ApiConstants.searchPageSize,
        history: historyUc.getHistory(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load next page of results.
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.query.isEmpty) return;
    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final searchUc = _ref.read(searchPinsUseCaseProvider);
      final results = await searchUc(
        query: state.query,
        page: nextPage,
        perPage: ApiConstants.searchPageSize,
      );
      state = state.copyWith(
        results: [...state.results, ...results],
        currentPage: nextPage,
        isLoadingMore: false,
        hasMore: results.length >= ApiConstants.searchPageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Pull-to-refresh search results.
  Future<void> refresh() async {
    if (state.query.isEmpty) {
      await initialize();
      return;
    }
    
    // Pick a random page for search refresh to show variety
    final randomPage = (math.Random().nextInt(5) + 1);
    
    state = state.copyWith(isLoading: true, error: null);
    try {
       final searchUc = _ref.read(searchPinsUseCaseProvider);
       final results = await searchUc(
         query: state.query,
         page: randomPage,
         perPage: ApiConstants.searchPageSize,
       );
       
       // Shuffle for variety
       final shuffled = List<Pin>.from(results)..shuffle();

       state = state.copyWith(
         results: shuffled,
         currentPage: randomPage,
         isLoading: false,
         hasMore: results.length >= ApiConstants.searchPageSize,
       );
    } catch (e) {
       state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearching(bool isSearching) {
    state = state.copyWith(isSearching: isSearching);
  }

  void clearSearch() {
    state = state.copyWith(
      query: '',
      results: [],
      suggestions: [],
      isSearching: false,
    );
  }

  void clearHistory() {
    _ref.read(searchHistoryUseCaseProvider).clearHistory();
    state = state.copyWith(history: []);
  }
}

// ── Provider ──

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});
