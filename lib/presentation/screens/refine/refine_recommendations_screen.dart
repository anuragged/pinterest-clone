import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../providers/board_provider.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/pin_card.dart';

class RefineRecommendationsScreen extends ConsumerStatefulWidget {
  const RefineRecommendationsScreen({super.key});

  @override
  ConsumerState<RefineRecommendationsScreen> createState() => _RefineRecommendationsScreenState();
}

class _RefineRecommendationsScreenState extends ConsumerState<RefineRecommendationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 2); // Initial index 2 is 'Boards' as per screenshot
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Refine your recommendations',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          dividerColor: Colors.transparent,
          indicatorColor: Theme.of(context).colorScheme.onSurface,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: Theme.of(context).colorScheme.onSurface,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Pins'),
            Tab(text: 'Interests'),
            Tab(text: 'Boards'),
            Tab(text: 'Following'),
            Tab(text: 'GenAI interests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPinsTab(),
          const Center(child: Text('Interests')),
          _buildBoardsTab(),
          const Center(child: Text('Following')),
          const Center(child: Text('GenAI interests')),
        ],
      ),
    );
  }

  Widget _buildBoardsTab() {
    final boards = ref.watch(boardProvider).boards;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Switch off a board to remove its Home tab and recommendations. Don\'t worry, this won\'t affect your board.',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        ...boards.map((board) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: board.coverImageUrls.isNotEmpty
                    ? Image.network(
                        board.coverImageUrls.first,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        color: PinColors.backgroundWash,
                        child: const Icon(Icons.grid_view_rounded, size: 20),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      board.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${board.pinCount} Pins • 3y', // Static time for now to match screenshot
                      style: const TextStyle(
                        fontSize: 12,
                        color: PinColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: true,
                onChanged: (val) {},
                activeColor: PinColors.pinterestRed,
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildPinsTab() {
    final pins = ref.watch(feedProvider).pins;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Hide Pins you\'ve saved or viewed close up',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.6,
            ),
            itemCount: pins.length,
            itemBuilder: (context, index) {
              final pin = pins[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            pin.thumbnailUrl,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.visibility_off_outlined,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '3 years ago',
                    style: TextStyle(
                      fontSize: 12,
                      color: PinColors.textSecondary,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
