import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/pin.dart';
import '../../domain/usecases/manage_boards.dart';
import '../../data/repositories/board_repository_impl.dart';
import 'feed_provider.dart';

// ── Board Repository Provider ──

final boardRepositoryProvider = Provider<BoardRepositoryImpl>((ref) {
  return BoardRepositoryImpl(ref.read(localCacheServiceProvider));
});

// ── Use Case Providers ──

final getBoardsUseCaseProvider = Provider<GetBoards>((ref) {
  return GetBoards(ref.read(boardRepositoryProvider));
});

final createBoardUseCaseProvider = Provider<CreateBoard>((ref) {
  return CreateBoard(ref.read(boardRepositoryProvider));
});

final addPinToBoardUseCaseProvider = Provider<AddPinToBoard>((ref) {
  return AddPinToBoard(ref.read(boardRepositoryProvider));
});

final updateBoardUseCaseProvider = Provider<UpdateBoard>((ref) {
  return UpdateBoard(ref.read(boardRepositoryProvider));
});

// ── Board State ──

class BoardState {
  final List<Board> boards;
  final bool isLoading;
  final String? error;

  const BoardState({
    this.boards = const [],
    this.isLoading = false,
    this.error,
  });

  BoardState copyWith({
    List<Board>? boards,
    bool? isLoading,
    String? error,
  }) {
    return BoardState(
      boards: boards ?? this.boards,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ── Board Notifier ──

class BoardNotifier extends StateNotifier<BoardState> {
  final Ref _ref;

  BoardNotifier(this._ref) : super(const BoardState());

  Future<void> loadBoards() async {
    state = state.copyWith(isLoading: true);
    try {
      final boards = await _ref.read(getBoardsUseCaseProvider)();
      state = state.copyWith(boards: boards, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadBoards();
    // Shuffle the boards for a visual change on refresh
    final shuffled = List<Board>.from(state.boards)..shuffle();
    state = state.copyWith(boards: shuffled);
  }

  /// Create a new board. Returns the created board.
  Future<Board> createBoard({
    required String name,
    String? description,
    bool isSecret = false,
  }) async {
    final board = await _ref.read(createBoardUseCaseProvider)(
      name: name,
      description: description,
      isSecret: isSecret,
    );
    state = state.copyWith(boards: [...state.boards, board]);
    return board;
  }

  /// Save a pin to a board — one tap, no confirmation, optimistic UI.
  Future<void> savePinToBoard({
    required String boardId,
    required Pin pin,
  }) async {
    // Optimistic: update board immediately
    final addPinToBoard = _ref.read(addPinToBoardUseCaseProvider);
    final updatedBoard = await addPinToBoard(boardId, pin.id, pin.thumbnailUrl);

    // Update boards list
    final newBoards = state.boards
        .map((b) => b.id == boardId ? updatedBoard : b)
        .toList();
    state = state.copyWith(boards: newBoards);

    // Also save the pin as saved
    final savePin = _ref.read(savePinUseCaseProvider);
    final savedPin = await savePin(pin.id, boardId: boardId);

    // Update feed state with new saved status
    _ref.read(feedProvider.notifier).updatePin(savedPin);
  }

  /// Quick-save: save to most recent board or create "Quick Saves".
  Future<void> quickSave(Pin pin) async {
    Board targetBoard;
    if (state.boards.isEmpty) {
      targetBoard = await createBoard(name: 'Quick Saves');
    } else {
      targetBoard = state.boards.last;
    }
    await savePinToBoard(boardId: targetBoard.id, pin: pin);
  }

  /// Delete a board.
  Future<void> deleteBoard(String boardId) async {
    await _ref.read(boardRepositoryProvider).deleteBoard(boardId);
    state = state.copyWith(
      boards: state.boards.where((b) => b.id != boardId).toList(),
    );
  }

  /// Update board metadata.
  Future<void> updateBoard(Board board) async {
    final updatedBoard = await _ref.read(updateBoardUseCaseProvider)(board);
    state = state.copyWith(
      boards: state.boards.map((b) => b.id == board.id ? updatedBoard : b).toList(),
    );
  }
}

// ── Provider ──

final boardProvider = StateNotifierProvider<BoardNotifier, BoardState>((ref) {
  return BoardNotifier(ref);
});
