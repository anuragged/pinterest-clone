import '../entities/pin.dart';
import '../repositories/search_repository_interface.dart';

/// Use case: Search pins by query.
class SearchPins {
  final SearchRepositoryInterface _repository;

  SearchPins(this._repository);

  Future<List<Pin>> call({
    required String query,
    required int page,
    required int perPage,
  }) {
    return _repository.searchPins(query: query, page: page, perPage: perPage);
  }
}

/// Use case: Get search suggestions.
class GetSearchSuggestions {
  final SearchRepositoryInterface _repository;

  GetSearchSuggestions(this._repository);

  Future<List<String>> call(String query) {
    return _repository.getSuggestions(query);
  }
}

/// Use case: Manage local search history.
class ManageSearchHistory {
  final SearchRepositoryInterface _repository;

  ManageSearchHistory(this._repository);

  List<String> getHistory() => _repository.getSearchHistory();

  void addToHistory(String query) => _repository.addToSearchHistory(query);

  void clearHistory() => _repository.clearSearchHistory();
}
