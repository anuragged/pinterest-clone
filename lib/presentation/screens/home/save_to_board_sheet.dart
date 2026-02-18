import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/haptics.dart';
import '../../../domain/entities/pin.dart';
import '../../providers/board_provider.dart';

/// "Save to Board" bottom sheet — Figma Section 2: Home
/// Lists user's boards with search and create board option.
class SaveToBoardSheet extends ConsumerStatefulWidget {
  final Pin pin;

  const SaveToBoardSheet({
    super.key,
    required this.pin,
  });

  @override
  ConsumerState<SaveToBoardSheet> createState() => _SaveToBoardSheetState();
}

class _SaveToBoardSheetState extends ConsumerState<SaveToBoardSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boardState = ref.watch(boardProvider);
    final filteredBoards = boardState.boards.where((board) {
      if (_searchQuery.isEmpty) return true;
      return board.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : PinColors.borderDefault,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.pin.thumbnailUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 40,
                      height: 40,
                      color: PinColors.shimmerBase,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Save to board',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : PinColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF333333)
                    : PinColors.backgroundWash,
                borderRadius:
                    BorderRadius.circular(PinDimensions.buttonRadius),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: TextStyle(
                  color: isDark ? Colors.white : PinColors.textPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Search boards',
                  hintStyle: TextStyle(
                    color:
                        isDark ? Colors.white38 : PinColors.textSecondary,
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color:
                        isDark ? Colors.white38 : PinColors.iconSecondary,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Create new board button
          ListTile(
            onTap: () => _showCreateBoardDialog(context, isDark),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF333333)
                    : PinColors.backgroundWash,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.add,
                color: isDark ? Colors.white : PinColors.textPrimary,
              ),
            ),
            title: Text(
              'Create board',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : PinColors.textPrimary,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20),
          ),

          Divider(
            color: isDark ? Colors.white12 : PinColors.borderDefault,
            height: 1,
          ),

          // Board list
          if (filteredBoards.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.dashboard_outlined,
                    size: 40,
                    color:
                        isDark ? Colors.white24 : PinColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No boards yet'
                        : 'No matching boards',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? Colors.white54
                          : PinColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                ),
                itemCount: filteredBoards.length,
                itemBuilder: (context, index) {
                  final board = filteredBoards[index];
                  return ListTile(
                    onTap: () async {
                      Haptics.medium();
                      await ref.read(boardProvider.notifier).savePinToBoard(
                            boardId: board.id,
                            pin: widget.pin,
                          );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Saved to ${board.name}'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: board.coverImageUrls.isNotEmpty
                          ? Image.network(
                              board.coverImageUrls.first,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 48,
                                height: 48,
                                color: PinColors.shimmerBase,
                                child: const Icon(
                                  Icons.dashboard_outlined,
                                  color: PinColors.textSecondary,
                                  size: 20,
                                ),
                              ),
                            )
                          : Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF333333)
                                    : PinColors.backgroundWash,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.dashboard_outlined,
                                color: isDark
                                    ? Colors.white38
                                    : PinColors.textSecondary,
                                size: 20,
                              ),
                            ),
                    ),
                    title: Text(
                      board.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : PinColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${board.pinCount} pins',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.white38
                            : PinColors.textSecondary,
                      ),
                    ),
                    trailing: board.isSecret
                        ? Icon(
                            Icons.lock_outlined,
                            size: 16,
                            color: isDark
                                ? Colors.white38
                                : PinColors.iconSecondary,
                          )
                        : null,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showCreateBoardDialog(BuildContext context, bool isDark) {
    final nameController = TextEditingController();
    bool isSecret = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Create board',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : PinColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                style: TextStyle(
                  color: isDark ? Colors.white : PinColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Board name',
                  hintStyle: TextStyle(
                    color: isDark
                        ? Colors.white38
                        : PinColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF333333)
                      : PinColors.backgroundWash,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Keep this board secret',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : PinColors.textPrimary,
                    ),
                  ),
                  Switch.adaptive(
                    value: isSecret,
                    activeColor: PinColors.pinterestRed,
                    onChanged: (v) => setDialogState(() => isSecret = v),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.white70 : PinColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  Haptics.heavy();
                  final board =
                      await ref.read(boardProvider.notifier).createBoard(
                            name: nameController.text.trim(),
                            isSecret: isSecret,
                          );
                  await ref.read(boardProvider.notifier).savePinToBoard(
                        boardId: board.id,
                        pin: widget.pin,
                      );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Saved to ${nameController.text.trim()}',
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PinColors.pinterestRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
