import '../entities/board.dart';

/// Abstract contract for board data operations.
abstract class BoardRepositoryInterface {
  /// Get all user boards.
  Future<List<Board>> getBoards();

  /// Get a single board by ID.
  Future<Board> getBoardById(String id);

  /// Create a new board.
  Future<Board> createBoard({
    required String name,
    String? description,
    bool isSecret = false,
  });

  /// Delete a board.
  Future<void> deleteBoard(String id);

  /// Add a pin to a board.
  Future<Board> addPinToBoard(String boardId, String pinId, String pinImageUrl);

  /// Remove a pin from a board.
  Future<Board> removePinFromBoard(String boardId, String pinId);

  /// Update board metadata.
  Future<Board> updateBoard(Board board);
}
