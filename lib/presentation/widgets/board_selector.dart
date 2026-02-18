import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../domain/entities/board.dart';
import '../../core/utils/haptics.dart';

/// Board selector bottom sheet for saving a pin to a specific board.
/// One-tap save, no confirmation dialog — optimistic UI.
class BoardSelector extends StatelessWidget {
  final List<Board> boards;
  final String? currentBoardId;
  final ValueChanged<Board> onBoardSelected;
  final VoidCallback onCreateBoard;

  const BoardSelector({
    super.key,
    required this.boards,
    this.currentBoardId,
    required this.onBoardSelected,
    required this.onCreateBoard,
  });

  /// Show as bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required List<Board> boards,
    String? currentBoardId,
    required ValueChanged<Board> onBoardSelected,
    required VoidCallback onCreateBoard,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PinDimensions.cardRadiusLarge),
        ),
      ),
      builder: (_) => BoardSelector(
        boards: boards,
        currentBoardId: currentBoardId,
        onBoardSelected: onBoardSelected,
        onCreateBoard: onCreateBoard,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PinColors.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: PinDimensions.paddingL, vertical: 8),
              child: Text(
                'Save to board',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

            Divider(height: 1, color: Theme.of(context).dividerColor),

            // Board list
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: PinDimensions.paddingL),
                children: [
                  // Create new board option
                  _buildCreateBoardTile(context),
                  const SizedBox(height: 8),

                  // Existing boards
                  ...boards.map((board) => _buildBoardTile(context, board)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCreateBoardTile(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface),
      ),
      title: Text(
        'Create board',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      onTap: () {
        Haptics.heavy();
        Navigator.pop(context);
        onCreateBoard();
      },
    );
  }

  Widget _buildBoardTile(BuildContext context, Board board) {
    final isSelected = board.id == currentBoardId;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          image: board.coverImages.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(board.coverImages.first),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: board.coverImages.isEmpty
            ? const Icon(
                Icons.dashboard_outlined,
                color: PinColors.textSecondary,
                size: 20,
              )
            : null,
      ),
      title: Text(
        board.name,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        '${board.pinCount} Pin${board.pinCount != 1 ? 's' : ''}',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.onSurface)
          : null,
      onTap: () {
        Haptics.medium();
        Navigator.pop(context);
        onBoardSelected(board);
      },
    );
  }
}
