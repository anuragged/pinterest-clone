import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/haptics.dart';
import '../../providers/feed_provider.dart';
import '../../providers/board_provider.dart';
import '../../widgets/pin_card.dart';
import '../../widgets/shimmer_grid.dart';
import '../../widgets/pin_action_menu.dart';
import 'save_to_board_sheet.dart';
import 'send_pin_sheet.dart';
import 'hide_pin_screen.dart';
import '../../widgets/pinterest_refresh_indicator.dart';

/// Home feed screen — the core Pinterest experience.
/// Masonry grid, infinite scroll, pull-to-refresh, scroll preservation.
/// Figma-matching "All" / "Following" tabs.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late ScrollController _scrollController;

  @override
  bool get wantKeepAlive => true; // Preserve state across tab switches

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Load feed on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final feedState = ref.read(feedProvider);
      if (feedState.pins.isEmpty && !feedState.isLoading) {
        ref.read(feedProvider.notifier).loadFeed();
      }

      // Restore scroll position
      if (feedState.scrollOffset > 0 && _scrollController.hasClients) {
        _scrollController.jumpTo(feedState.scrollOffset);
      }

      // Initialize boards
      ref.read(boardProvider.notifier).loadBoards();
    });
  }

  @override
  void dispose() {
    // Save scroll position before dispose
    if (_scrollController.hasClients) {
      ref.read(feedProvider.notifier).saveScrollOffset(
            _scrollController.offset,
          );
    }
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final threshold = maxScroll * ApiConstants.prefetchThreshold;

    // Prefetch at 70%
    if (currentScroll >= threshold) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  void _showPinActionMenu(BuildContext context, dynamic pin, Offset position) {
    Haptics.medium();
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => PinActionMenu(
        pinTitle: pin.title ?? 'Pin',
        pinImageUrl: pin.thumbnailUrl,
        position: position,
        onSave: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => SaveToBoardSheet(pin: pin),
          );
        },
        onHide: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HidePinScreen(
                pinImageUrl: pin.thumbnailUrl,
                pinTitle: pin.title ?? 'Pin',
                onDone: () {
                  // Logic to remove from feed if needed
                },
              ),
            ),
          );
        },
        onShare: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => SendPinSheet(
              pinImageUrl: pin.thumbnailUrl,
              pinTitle: pin.title ?? 'Pin',
            ),
          );
        },
        onReport: () {
          // Link action or Report
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link copied to clipboard')),
          );
        },
      ),
    );
  }

  void _showSavedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Saved to Profile'),
          ],
        ),
        backgroundColor: PinColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Edit',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final feedState = ref.watch(feedProvider);
    final columns = Responsive.gridColumns(context);
    final spacing = Responsive.gridSpacing(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: feedState.isLoading && feedState.pins.isEmpty
            ? const ShimmerGrid()
            : PinterestRefreshIndicator(
                onRefresh: () async {
                  await ref.read(feedProvider.notifier).refresh();
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // Top padding instead of header
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),

                      // ── Masonry Grid ──
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: spacing),
                        sliver: SliverMasonryGrid.count(
                          crossAxisCount: columns,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          childCount: feedState.pins.length,
                          itemBuilder: (context, index) {
                            final pin = feedState.pins[index];
                            return PinCard(
                              pin: pin,
                              heroTag: 'pin_${pin.id}',
                              onTap: () {
                                ref.read(feedProvider.notifier).saveScrollOffset(
                                      _scrollController.offset,
                                    );
                                context.push('/pin/${pin.id}');
                              },
                              onSave: () {
                                ref.read(boardProvider.notifier).quickSave(pin);
                                _showSavedSnackBar();
                              },
                              onLongPress: (position) {
                                // Figma: Long-press shows radial action menu
                                _showPinActionMenu(
                                  context,
                                  pin,
                                  position,
                                );
                              },
                            );
                          },
                        ),
                      ),

                    // ── Loading more shimmer ──
                    if (feedState.isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: ShimmerGrid(itemCount: 4, isInline: true),
                        ),
                      ),

                    // ── Error state ──
                    if (feedState.error != null)
                      SliverToBoxAdapter(
                        child: _buildErrorWidget(feedState.error!),
                      ),

                    // ── Bottom padding ──
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHomeHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Pinterest logo
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: PinColors.pinterestRed,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'P',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 48,
              child: TabBar(
                isScrollable: true,
                dividerColor: Colors.transparent,
                indicatorColor: Theme.of(context).colorScheme.onSurface,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 3,
                labelColor: Theme.of(context).colorScheme.onSurface,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Following'),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => context.push('/refine-recommendations'),
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? PinColors.backgroundWash.withValues(alpha: 0.5)
                    : const Color(0xFF333333),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_mosaic_outlined,
                size: 20,
                color: Theme.of(context).brightness == Brightness.light
                    ? PinColors.textPrimary
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(feedProvider.notifier).loadFeed(),
            style: ElevatedButton.styleFrom(
              backgroundColor: PinColors.pinterestRed,
              foregroundColor: PinColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
