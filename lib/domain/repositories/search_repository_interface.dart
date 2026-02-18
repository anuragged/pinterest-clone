import '../entities/pin.dart';

/// Abstract contract for search operations.
abstract class SearchRepositoryInterface {
  /// Search pins by query string.
  Future<List<Pin>> searchPins({
    required String query,
    required int page,
    required int perPage,
  });

  /// Get search suggestions based on partial query.
  Future<List<String>> getSuggestions(String query);

  /// Get cached search history.
  List<String> getSearchHistory();

  /// Add a query to search history.
  void addToSearchHistory(String query);

  /// Clear search history.
  void clearSearchHistory();

  /// Get trending/popular search terms.
  Future<List<String>> getTrendingSearches();
}
