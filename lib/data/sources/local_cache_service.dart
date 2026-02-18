import '../../domain/entities/pin.dart';
import '../../domain/entities/board.dart';
import '../../data/models/board_model.dart';

/// In-memory local cache for saved pins, boards, search history,
/// and click/save counts. Persists for the session lifetime.
class LocalCacheService {
  // Saved pins: pinId → Pin
  final Map<String, Pin> _savedPins = {};

  // Boards: boardId → BoardModel
  final Map<String, BoardModel> _boards = {};

  // Click counts: pinId → count
  final Map<String, int> _clickCounts = {};

  // Save counts: pinId → count
  final Map<String, int> _saveCounts = {};

  // Search history
  final List<String> _searchHistory = [];

  // ── Saved Pins ──

  List<Pin> get savedPins => _savedPins.values.toList();

  bool isPinSaved(String pinId) => _savedPins.containsKey(pinId);

  void savePin(Pin pin) {
    _savedPins[pin.id] = pin;
    _saveCounts[pin.id] = (_saveCounts[pin.id] ?? 0) + 1;
  }

  void unsavePin(String pinId) {
    _savedPins.remove(pinId);
  }

  // ── Click Tracking ──

  void recordClick(String pinId) {
    _clickCounts[pinId] = (_clickCounts[pinId] ?? 0) + 1;
  }

  int getClickCount(String pinId) => _clickCounts[pinId] ?? 0;
  int getSaveCount(String pinId) => _saveCounts[pinId] ?? 0;

  /// Enrich a pin with local save/click data.
  Pin enrichPin(Pin pin) {
    return pin.copyWith(
      isSaved: _savedPins.containsKey(pin.id),
      saves: pin.saves + (_saveCounts[pin.id] ?? 0),
      clicks: pin.clicks + (_clickCounts[pin.id] ?? 0),
      savedToBoardId: _savedPins[pin.id]?.savedToBoardId,
    );
  }

  // ── Boards ──

  List<Board> get boards => _boards.values.toList();

  Board? getBoard(String id) => _boards[id];

  void putBoard(BoardModel board) {
    _boards[board.id] = board;
  }

  void removeBoard(String id) {
    _boards.remove(id);
  }

  // ── Search History ──

  List<String> get searchHistory => List.unmodifiable(_searchHistory);

  void addSearchQuery(String query) {
    _searchHistory.remove(query); // Remove duplicate
    _searchHistory.insert(0, query);
    if (_searchHistory.length > 20) {
      _searchHistory.removeLast();
    }
  }

  void clearSearchHistory() {
    _searchHistory.clear();
  }

  // ── User Interests ──

  Set<int> get userInterests {
    return _savedPins.values.map((p) => p.photographerId).toSet();
  }
}
