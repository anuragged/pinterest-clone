import '../../domain/entities/pin.dart';
import '../../domain/repositories/search_repository_interface.dart';
import '../sources/pexels_api_service.dart';
import '../sources/local_cache_service.dart';

/// Concrete implementation of SearchRepositoryInterface.
class SearchRepositoryImpl implements SearchRepositoryInterface {
  final PexelsApiService _apiService;
  final LocalCacheService _cacheService;

  SearchRepositoryImpl(this._apiService, this._cacheService);

  @override
  Future<List<Pin>> searchPins({
    required String query,
    required int page,
    required int perPage,
  }) async {
    final pins = await _apiService.searchPhotos(
      query: query,
      page: page,
      perPage: perPage,
    );
    return pins.map((pin) => _cacheService.enrichPin(pin)).toList();
  }

  @override
  Future<List<String>> getSuggestions(String query) async {
    // Generate suggestions from search history + predefined categories
    final history = _cacheService.searchHistory;
    final suggestions = <String>[];

    // Match from history
    for (final item in history) {
      if (item.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(item);
      }
    }

    // Add category-based suggestions
    final categories = _defaultCategories
        .where((c) => c.toLowerCase().contains(query.toLowerCase()))
        .toList();
    suggestions.addAll(categories);

    return suggestions.toSet().take(8).toList();
  }

  @override
  List<String> getSearchHistory() {
    return _cacheService.searchHistory;
  }

  @override
  void addToSearchHistory(String query) {
    _cacheService.addSearchQuery(query);
  }

  @override
  void clearSearchHistory() {
    _cacheService.clearSearchHistory();
  }

  @override
  Future<List<String>> getTrendingSearches() async {
    // Return predefined trending topics
    return _trendingSearches;
  }

  static const List<String> _defaultCategories = [
    'Architecture',
    'Art',
    'Animals',
    'Beauty',
    'Cars',
    'Design',
    'DIY',
    'Fashion',
    'Film',
    'Fitness',
    'Food',
    'Garden',
    'Hair',
    'Home Decor',
    'Illustration',
    'Interior',
    'Landscape',
    'Minimalist',
    'Nature',
    'Photography',
    'Quotes',
    'Street Style',
    'Tattoo',
    'Travel',
    'Typography',
    'Wallpaper',
    'Wedding',
  ];

  static const List<String> _trendingSearches = [
    'Aesthetic wallpaper',
    'Modern home decor',
    'Street photography',
    'Minimalist design',
    'Travel destinations',
    'Food photography',
    'Fashion inspiration',
    'Nature landscape',
    'Digital art',
    'Architecture modern',
  ];
}
