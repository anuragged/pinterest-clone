import '../entities/board.dart';
import '../repositories/board_repository_interface.dart';

/// Use case: Get all user boards.
class GetBoards {
  final BoardRepositoryInterface _repository;

  GetBoards(this._repository);

  Future<List<Board>> call() => _repository.getBoards();
}

/// Use case: Create a new board.
class CreateBoard {
  final BoardRepositoryInterface _repository;

  CreateBoard(this._repository);

  Future<Board> call({
    required String name,
    String? description,
    bool isSecret = false,
  }) {
    return _repository.createBoard(
      name: name,
      description: description,
      isSecret: isSecret,
    );
  }
}

/// Use case: Add a pin to a board (one-tap save, optimistic).
class AddPinToBoard {
  final BoardRepositoryInterface _repository;

  AddPinToBoard(this._repository);

  Future<Board> call(String boardId, String pinId, String pinImageUrl) {
    return _repository.addPinToBoard(boardId, pinId, pinImageUrl);
  }
}

/// Use case: Remove a pin from a board.
class RemovePinFromBoard {
  final BoardRepositoryInterface _repository;

  RemovePinFromBoard(this._repository);

  Future<Board> call(String boardId, String pinId) {
    return _repository.removePinFromBoard(boardId, pinId);
  }
}

/// Use case: Delete a board.
class DeleteBoard {
  final BoardRepositoryInterface _repository;

  DeleteBoard(this._repository);

  Future<void> call(String id) => _repository.deleteBoard(id);
}

/// Use case: Update board metadata.
class UpdateBoard {
  final BoardRepositoryInterface _repository;

  UpdateBoard(this._repository);

  Future<Board> call(Board board) => _repository.updateBoard(board);
}
