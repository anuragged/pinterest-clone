import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../providers/board_provider.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/pin_card.dart';
import 'edit_board_screen.dart';
import 'invite_collaborators_sheet.dart';
import 'select_pins_screen.dart';
import '../../../domain/entities/pin.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// Board detail screen showing all pins in a board.
class BoardDetailScreen extends ConsumerWidget {
  final String boardId;

  const BoardDetailScreen({super.key, required this.boardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardState = ref.watch(boardProvider);
    final board = boardState.boards.where((b) => b.id == boardId).firstOrNull;

    if (board == null) {
      return Scaffold(
        backgroundColor: PinColors.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: PinColors.backgroundPrimary,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: PinColors.iconDefault),
          ),
        ),
        body: const Center(
          child: Text(
            'Board not found',
            style: TextStyle(
              fontSize: 16,
              color: PinColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: PinColors.backgroundPrimary,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──
          SliverAppBar(
            backgroundColor: PinColors.backgroundPrimary,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon:
                  const Icon(Icons.arrow_back, color: PinColors.iconDefault),
            ),
            actions: [
              IconButton(
                onPressed: () => _showMoreMenu(context, board, ref),
                icon: const Icon(Icons.more_horiz,
                    color: PinColors.iconDefault),
              ),
            ],
          ),

          // ── Board header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PinDimensions.paddingXXL,
                vertical: PinDimensions.paddingL,
              ),
              child: Column(
                children: [
                  // Board name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (board.isSecret)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.lock_outline,
                              size: 20, color: PinColors.textSecondary),
                        ),
                      Text(
                        board.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: PinColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${board.pinCount} Pin${board.pinCount != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: PinColors.textSecondary,
                    ),
                  ),
                  if (board.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      board.description!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: PinColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Pins grid ──
          if (board.pinIds.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.push_pin_outlined,
                      size: 48,
                      color: PinColors.textSecondary,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No pins in this board yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: PinColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childCount: board.pinIds.length,
                itemBuilder: (context, index) {
                  // Simulate Pin objects from the board's stored cover images
                  final imageUrl = board.coverImageUrls.length > index 
                      ? board.coverImageUrls[index] 
                      : 'https://via.placeholder.com/300';
                  
                  // Create a dummy dynamic Pin object for the PinCard
                  // In a real app, this would be fetched from a repository
                  return PinCard(
                    pin: Pin(
                      id: board.pinIds[index],
                      imageUrl: imageUrl,
                      thumbnailUrl: imageUrl,
                      width: 300,
                      height: (300 * (1.0 + (index % 3) * 0.2)).toInt(),
                      photographerName: 'Contributor',
                      photographerId: 0,
                      avgColor: '#E60023',
                      createdAt: DateTime.now(),
                    ),
                    heroTag: 'board_pin_${board.pinIds[index]}',
                    onTap: () {
                      context.push('/pin/${board.pinIds[index]}');
                    },
                    onSave: () {},
                  );
                },
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  void _showMoreMenu(BuildContext context, dynamic board, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1A1A)
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Options',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white54
                      : PinColors.textSecondary,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectPinsScreen(board: board),
                  ),
                );
              },
              title: const Text('Select Pins', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditBoardScreen(board: board),
                  ),
                );
              },
              title: const Text('Edit board', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(ctx);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => InviteCollaboratorsSheet(boardName: board.name),
                );
              },
              title: const Text('Invite collaborators', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ListTile(
              onTap: () => Navigator.pop(ctx),
              title: const Text('Share board', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ListTile(
              onTap: () => Navigator.pop(ctx),
              title: const Text('Archive board', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
