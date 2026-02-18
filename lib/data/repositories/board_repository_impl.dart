import '../../domain/entities/board.dart';
import '../../domain/repositories/board_repository_interface.dart';
import '../models/board_model.dart';
import '../sources/local_cache_service.dart';

/// Concrete implementation of BoardRepositoryInterface.
/// All board data is stored locally (in-memory cache).
class BoardRepositoryImpl implements BoardRepositoryInterface {
  final LocalCacheService _cacheService;
  int _nextBoardId = 1;

  BoardRepositoryImpl(this._cacheService);

  @override
  Future<List<Board>> getBoards() async {
    return _cacheService.boards;
  }

  @override
  Future<Board> getBoardById(String id) async {
    final board = _cacheService.getBoard(id);
    if (board == null) throw Exception('Board not found: $id');
    return board;
  }

  @override
  Future<Board> createBoard({
    required String name,
    String? description,
    bool isSecret = false,
  }) async {
    final now = DateTime.now();
    final board = BoardModel(
      id: 'board_${_nextBoardId++}',
      name: name,
      description: description,
      pinIds: const [],
      coverImageUrls: const [],
      isSecret: isSecret,
      createdAt: now,
      updatedAt: now,
    );
    _cacheService.putBoard(board);
    return board;
  }

  @override
  Future<void> deleteBoard(String id) async {
    _cacheService.removeBoard(id);
  }

  @override
  Future<Board> addPinToBoard(String boardId, String pinId, String pinImageUrl) async {
    final board = _cacheService.getBoard(boardId);
    if (board == null) throw Exception('Board not found: $boardId');

    if (board.pinIds.contains(pinId)) return board;

    final updatedBoard = BoardModel(
      id: board.id,
      name: board.name,
      description: board.description,
      pinIds: [...board.pinIds, pinId],
      coverImageUrls: [...board.coverImageUrls, pinImageUrl],
      isSecret: board.isSecret,
      createdAt: board.createdAt,
      updatedAt: DateTime.now(),
    );
    _cacheService.putBoard(updatedBoard);
    return updatedBoard;
  }

  @override
  Future<Board> removePinFromBoard(String boardId, String pinId) async {
    final board = _cacheService.getBoard(boardId);
    if (board == null) throw Exception('Board not found: $boardId');

    final pinIndex = board.pinIds.indexOf(pinId);
    if (pinIndex == -1) return board;

    final newPinIds = List<String>.from(board.pinIds)..removeAt(pinIndex);
    final newCovers = List<String>.from(board.coverImageUrls);
    if (pinIndex < newCovers.length) newCovers.removeAt(pinIndex);

    final updatedBoard = BoardModel(
      id: board.id,
      name: board.name,
      description: board.description,
      pinIds: newPinIds,
      coverImageUrls: newCovers,
      isSecret: board.isSecret,
      createdAt: board.createdAt,
      updatedAt: DateTime.now(),
    );
    _cacheService.putBoard(updatedBoard);
    return updatedBoard;
  }

  @override
  Future<Board> updateBoard(Board board) async {
    final model = BoardModel(
      id: board.id,
      name: board.name,
      description: board.description,
      pinIds: board.pinIds,
      coverImageUrls: board.coverImageUrls,
      isSecret: board.isSecret,
      createdAt: board.createdAt,
      updatedAt: DateTime.now(),
    );
    _cacheService.putBoard(model);
    return model;
  }
}
