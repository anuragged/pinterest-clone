import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/haptics.dart';
import '../../../domain/entities/pin.dart';
import '../../providers/pin_detail_provider.dart';
import '../../providers/board_provider.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/save_button.dart';
import '../../widgets/pin_card.dart';
import '../../widgets/board_selector.dart';
import '../../widgets/shimmer_grid.dart';
import '../../widgets/action_button.dart';
import '../../widgets/pin_action_menu.dart';

/// Pin detail page.
/// Mobile: full-screen page. Desktop: could be a modal overlay.
/// Image + right panel (save, board selector, title, description, comments).
/// Related pins load immediately below — no dead ends.
class PinDetailScreen extends ConsumerStatefulWidget {
  final String pinId;

  const PinDetailScreen({super.key, required this.pinId});

  @override
  ConsumerState<PinDetailScreen> createState() => _PinDetailScreenState();
}

class _PinDetailScreenState extends ConsumerState<PinDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Try to set pin from feed cache for instant display
      final feedState = ref.read(feedProvider);
      final cachedPin = feedState.pins.where((p) => p.id == widget.pinId).firstOrNull;
      if (cachedPin != null) {
        ref.read(pinDetailProvider.notifier).setPinFromCache(cachedPin);
      } else {
        ref.read(pinDetailProvider.notifier).loadPin(widget.pinId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= maxScroll * 0.7) {
      ref.read(pinDetailProvider.notifier).loadMoreRelated();
    }
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceFirst('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return PinColors.shimmerBase;
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(pinDetailProvider);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: detailState.isLoading && detailState.pin == null
          ? const Center(
              child: CircularProgressIndicator(
                color: PinColors.pinterestRed,
                strokeWidth: 2.5,
              ),
            )
          : detailState.pin == null
              ? _buildError()
              : _buildContent(detailState, isMobile),
    );
  }

  Widget _buildContent(PinDetailState state, bool isMobile) {
    final pin = state.pin!;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // ── App bar ──
        SliverAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leadingWidth: 70,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Center(
              child: PinActionButton(
                icon: Icons.chevron_left,
                iconSize: 32,
                onTap: () => context.pop(),
              ),
            ),
          ),
          actions: [
            PinActionButton(
              icon: Icons.upload_outlined,
              onTap: () {},
            ),
            const SizedBox(width: 12),
            PinActionButton(
              icon: Icons.more_horiz,
              onTap: () {},
            ),
            const SizedBox(width: 16),
          ],
        ),

        // ── Main content ──
        SliverToBoxAdapter(
          child: isMobile
              ? _buildMobileLayout(pin)
              : _buildDesktopLayout(pin),
        ),

        // ── Related pins header ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Text(
              'More like this',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),

        // ── Related pins masonry grid ──
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: Responsive.gridColumns(context),
            mainAxisSpacing: Responsive.gridSpacing(context),
            crossAxisSpacing: Responsive.gridSpacing(context),
            childCount: state.relatedPins.length,
            itemBuilder: (context, index) {
              final relatedPin = state.relatedPins[index];
              return PinCard(
                pin: relatedPin,
                heroTag: 'related_${relatedPin.id}_$index',
                onTap: () => context.push('/pin/${relatedPin.id}'),
                onSave: () =>
                    ref.read(boardProvider.notifier).quickSave(relatedPin),
                onLongPress: (position) {
                  showDialog(
                    context: context,
                    barrierColor: Colors.black54,
                    builder: (ctx) => PinActionMenu(
                      pinTitle: relatedPin.title ?? 'Pin',
                      pinImageUrl: relatedPin.thumbnailUrl,
                      position: position,
                      onSave: () => Navigator.pop(ctx),
                      onHide: () => Navigator.pop(ctx),
                      onShare: () => Navigator.pop(ctx),
                      onReport: () => Navigator.pop(ctx),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // ── Loading more related ──
        if (state.isLoadingRelated)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: ShimmerGrid(itemCount: 4, isInline: true),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildMobileLayout(Pin pin) {
    final avgColor = _parseColor(pin.avgColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Image (full width) ──
        Hero(
          tag: 'pin_${pin.id}',
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(PinDimensions.cardRadiusLarge),
            ),
            child: CachedNetworkImage(
              imageUrl: pin.imageUrl,
              width: double.infinity,
              fit: BoxFit.fitWidth,
              placeholder: (_, __) => AspectRatio(
                aspectRatio: pin.aspectRatio.clamp(0.5, 2.0),
                child: Container(color: avgColor.withValues(alpha: 0.3)),
              ),
              errorWidget: (_, __, ___) => AspectRatio(
                aspectRatio: pin.aspectRatio.clamp(0.5, 2.0),
                child: Container(
                  color: avgColor.withValues(alpha: 0.3),
                  child: const Icon(Icons.broken_image_outlined, size: 48),
                ),
              ),
            ),
          ),
        ),

        // ── Details panel ──
        Padding(
          padding: const EdgeInsets.all(PinDimensions.paddingL),
          child: _buildDetailsPanel(pin),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(Pin pin) {
    final avgColor = _parseColor(pin.avgColor);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: PinDimensions.detailDesktopMaxWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.all(PinDimensions.paddingXXL),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image (~60% width) ──
              Expanded(
                flex: 6,
                child: Hero(
                  tag: 'pin_${pin.id}',
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(PinDimensions.cardRadiusLarge),
                    child: CachedNetworkImage(
                      imageUrl: pin.imageUrl,
                      fit: BoxFit.fitWidth,
                      placeholder: (_, __) => AspectRatio(
                        aspectRatio: pin.aspectRatio.clamp(0.5, 2.0),
                        child: Container(
                            color: avgColor.withValues(alpha: 0.3)),
                      ),
                      errorWidget: (_, __, ___) => AspectRatio(
                        aspectRatio: pin.aspectRatio.clamp(0.5, 2.0),
                        child: Container(
                          color: avgColor.withValues(alpha: 0.3),
                          child: const Icon(Icons.broken_image_outlined,
                              size: 48),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // ── Details panel (~40% width) ──
              Expanded(
                flex: 4,
                child: _buildDetailsPanel(pin),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsPanel(Pin pin) {
    final boards = ref.watch(boardProvider).boards;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Save row ──
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  BoardSelector.show(
                    context: context,
                    boards: boards,
                    currentBoardId: pin.savedToBoardId,
                    onBoardSelected: (board) {
                      ref.read(boardProvider.notifier).savePinToBoard(
                            boardId: board.id,
                            pin: pin,
                          );
                    },
                    onCreateBoard: () {
                      Haptics.heavy();
                      ref
                          .read(boardProvider.notifier)
                          .createBoard(name: 'New Board');
                    },
                  );
                },
                child: Container(
                  height: PinDimensions.buttonHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: PinColors.borderDefault),
                    borderRadius:
                        BorderRadius.circular(PinDimensions.buttonRadius),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          pin.savedToBoardId != null
                              ? _getBoardName(pin.savedToBoardId!, boards)
                              : 'Choose board',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                       Icon(Icons.keyboard_arrow_down,
                          color: Theme.of(context).colorScheme.onSurface),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SaveButton(
              isSaved: pin.isSaved,
              compact: false,
              onTap: () {
                ref.read(boardProvider.notifier).quickSave(pin);
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Title ──
        if (pin.title != null && pin.title!.isNotEmpty)
          Text(
            pin.title!,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.3,
            ),
          ),

        if (pin.title != null && pin.title!.isNotEmpty)
          const SizedBox(height: 8),

        // ── Description ──
        if (pin.description != null && pin.description!.isNotEmpty)
          Text(
            pin.description!,
            style: const TextStyle(
              fontSize: 14,
              color: PinColors.textSecondary,
              height: 1.5,
            ),
          ),

        const SizedBox(height: 20),

        // ── Creator info ──
        Row(
          children: [
            CircleAvatar(
              radius: PinDimensions.avatarMedium / 2,
              backgroundColor: PinColors.pinterestRed,
              child: Text(
                pin.photographerName.isNotEmpty
                    ? pin.photographerName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: PinColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pin.photographerName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Text(
                    'Photographer',
                    style: TextStyle(
                      fontSize: 12,
                      color: PinColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: PinColors.textPrimary,
                side: const BorderSide(color: PinColors.borderDefault),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: Text(
                'Follow',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        Divider(color: Theme.of(context).dividerColor),
        const SizedBox(height: 12),

        // ── Comments placeholder ──
        Text(
          'Comments',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'No comments yet. Add one to start a conversation.',
          style: TextStyle(
            fontSize: 14,
            color: PinColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _getBoardName(String boardId, List boards) {
    for (final board in boards) {
      if (board.id == boardId) return board.name;
    }
    return 'Board';
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              size: 48, color: PinColors.textSecondary),
          const SizedBox(height: 12),
          const Text(
            'Pin not found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PinColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: PinColors.pinterestRed,
              foregroundColor: PinColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('Go back'),
          ),
        ],
      ),
    );
  }
}
