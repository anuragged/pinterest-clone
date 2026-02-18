import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/haptics.dart';
import '../../providers/search_provider.dart';
import '../../widgets/pinterest_refresh_indicator.dart';
import '../../providers/board_provider.dart';
import '../../widgets/pin_card.dart';
import '../../widgets/shimmer_grid.dart';
import '../../widgets/category_chip.dart';

/// Search & Discovery screen.
/// Instant suggestions, live results, cached history, category chips.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController(viewportFraction: 0.9);
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  final List<Map<String, String>> _inspirationItems = [
    {
      'subtitle': 'Go for it',
      'title': 'Quotes to recharge your motivation',
      'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&q=80',
      'overlayText': 'BAD DAYS ARE TEMPORARY',
    },
    {
      'subtitle': 'Healthy & Sweet',
      'title': 'Time to try banana sushi',
      'image': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&q=80',
      'overlayText': 'YUMMY DESSERTS',
    },
    {
      'subtitle': 'Curated for you',
      'title': 'Your weekend guide to relaxing interiors',
      'image': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&q=80',
      'overlayText': 'COZY HOMES',
    },
    {
      'subtitle': 'Style Guide',
      'title': 'Level up your office attire',
      'image': 'https://images.unsplash.com/photo-1497215728101-856f4ea42174?auto=format&fit=crop&q=80',
      'overlayText': 'OFFICE STYLE',
    },
    {
      'subtitle': 'Winter Escape',
      'title': 'Cozy cabin mood boards',
      'image': 'https://images.unsplash.com/photo-1496307653780-42ee777d4838?auto=format&fit=crop&q=80',
      'overlayText': 'CABIN VIBES',
    },
    {
      'subtitle': 'Routine Refresh',
      'title': 'Morning routines for productivity',
      'image': 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&q=80',
      'overlayText': 'START FRESH',
    },
    {
      'subtitle': 'Green Living',
      'title': 'Aesthetic plants for small spaces',
      'image': 'https://images.unsplash.com/photo-1485955900006-10f4d324d411?auto=format&fit=crop&q=80',
      'overlayText': 'PLANT PARENT',
    },
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchProvider.notifier).initialize();
    });


    _focusNode.addListener(() {
      ref.read(searchProvider.notifier).setSearching(_focusNode.hasFocus);
    });

    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % 7;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= maxScroll * 0.7) {
      ref.read(searchProvider.notifier).loadMore();
    }
  }

  void _onSearch(String query) {
    _focusNode.unfocus();
    ref.read(searchProvider.notifier).search(query);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Bar ──
            _buildSearchBar(searchState),

            // ── Content ──
            Expanded(
              child: PinterestRefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _inspirationItems.shuffle();
                  });
                  await ref.read(searchProvider.notifier).refresh();
                },
                child: searchState.isSearching
                    ? _buildSuggestionsAndHistory(searchState)
                    : searchState.results.isNotEmpty
                        ? _buildResults(searchState)
                        : _buildDiscovery(searchState),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(SearchState searchState) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PinDimensions.paddingL,
        vertical: PinDimensions.paddingS,
      ),
      child: Container(
        height: PinDimensions.searchBarHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white.withValues(alpha: 0.1) 
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(PinDimensions.searchBarRadius),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                size: 22,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                onChanged: (q) => ref.read(searchProvider.notifier).updateQuery(q),
                onSubmitted: _onSearch,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search for a project of any size',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (searchState.query.isNotEmpty)
              IconButton(
                onPressed: () {
                  _textController.clear();
                  ref.read(searchProvider.notifier).clearSearch();
                },
                icon: const Icon(Icons.close, size: 20),
              ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.camera_alt,
                color: PinColors.iconSecondary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsAndHistory(SearchState searchState) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: PinDimensions.paddingL),
      children: [
        // Suggestions
        if (searchState.suggestions.isNotEmpty) ...[
          ...searchState.suggestions.map((s) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.search,
                    color: PinColors.iconSecondary, size: 20),
                title: Text(s,
                    style: const TextStyle(
                        fontSize: 15, color: PinColors.textPrimary)),
                onTap: () {
                  Haptics.light();
                  _textController.text = s;
                  _onSearch(s);
                },
              )),
          const Divider(color: PinColors.borderLight),
        ],

        // History
        if (searchState.query.isEmpty && searchState.history.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: PinColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(searchProvider.notifier).clearHistory(),
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    fontSize: 14,
                    color: PinColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          ...searchState.history.map((h) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history,
                    color: PinColors.iconSecondary, size: 20),
                title: Text(h,
                    style: const TextStyle(
                        fontSize: 15, color: PinColors.textPrimary)),
                onTap: () {
                  _textController.text = h;
                  _onSearch(h);
                },
              )),
        ],
      ],
    );
  }

  Widget _buildDiscovery(SearchState searchState) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ideas for you (Grid) ──
          _buildDiscoveryHeader('Ideas for you'),
          _buildIdeasForYouGrid(),

          const SizedBox(height: 32),

          // ── Today's Inspiration (Carousel) ──
          _buildDiscoveryHeader('Today\'s Inspiration'),
          _buildTodayInspirationCarousel(),

          const SizedBox(height: 32),

          // ── Explore featured boards ──
          _buildDiscoveryHeader('Explore featured boards'),
          const Padding(
            padding: EdgeInsets.only(left: 20, bottom: 16),
            child: Text(
              'Ideas you might like',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          _buildExploreFeaturedBoards(),

          const SizedBox(height: 32),

          // ── Ideas from creators (Horizontal List) ──
          _buildDiscoveryHeader('Ideas from creators'),
          _buildIdeasFromCreators(),

          const SizedBox(height: 32),

          // ── Shopping spotlight ──
          _buildDiscoveryHeader('Shopping spotlight'),
          _buildSpotlightCard(
            'The take-care-of-yourself edit',
            'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&q=80',
          ),

          const SizedBox(height: 48),

          // ── Popular on Pinterest ──
          _buildPopularOnPinterest(),
        ],
      ),
    );
  }

  Widget _buildDiscoveryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 12, top: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildIdeasForYouGrid() {
    final List<Map<String, String>> categories = [
      {'name': 'Interior design', 'image': 'https://images.unsplash.com/photo-1616489953149-75ec07aa2221?auto=format&fit=crop&q=80'},
      {'name': 'Outfit ideas', 'image': 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&q=80'},
      {'name': 'Cooking recipes', 'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&q=80'},
      {'name': 'Art inspiration', 'image': 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?auto=format&fit=crop&q=80'},
      {'name': 'Travel destinations', 'image': 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&q=80'},
      {'name': 'DIY projects', 'image': 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&q=80'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.8,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () {
              Haptics.light();
              _textController.text = cat['name']!;
              _onSearch(cat['name']!);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Image.network(
                    cat['image']!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black54, Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      cat['name']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayInspirationCarousel() {
    return SizedBox(
      height: 480,
      child: PageView.builder(
        itemCount: _inspirationItems.length,
        controller: _pageController,
        onPageChanged: (idx) => _currentPage = idx,
        itemBuilder: (context, index) {
          final item = _inspirationItems[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () {
                Haptics.medium();
                context.push('/today-inspiration');
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(PinDimensions.cardRadius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      item['image']!,
                      fit: BoxFit.cover,
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.9),
                            ],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Centered Overlay Text (Figma style)
                    if (item['overlayText'] != null)
                      Center(
                        child: Text(
                          item['overlayText']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Courier', // For that handwritten/stylized look
                            letterSpacing: 2.0,
                            shadows: [
                               Shadow(
                                  color: Colors.black45,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                               ),
                            ],
                          ),
                        ),
                      ),
                    // "Today" Badge
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Today',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 48,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['subtitle']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Dots
                    Positioned(
                       bottom: 20,
                       left: 0,
                       right: 0,
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: List.generate(
                           _inspirationItems.length,
                           (i) => Container(
                             margin: const EdgeInsets.symmetric(horizontal: 3),
                             width: 6,
                             height: 6,
                             decoration: BoxDecoration(
                               shape: BoxShape.circle,
                               color: i == index ? Colors.white : Colors.white24,
                             ),
                           ),
                         ),
                       ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIdeasFromCreators() {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 150,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage('https://picsum.photos/seed/${index + 100}/300/400'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -15,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/100?u=$index'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Creator Name',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSpotlightCard(String title, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PinDimensions.cardRadius),
        child: Stack(
          children: [
            Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black87,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'SHOP THE LOOK',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularOnPinterest() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDiscoveryHeader('Popular on Pinterest'),
        _buildPopularTopicSection('Holi video', [
          'https://images.unsplash.com/photo-1540544660406-6a69dacb2804?auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1563294371-bd38fa79222b?auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1470509037663-253afd7f0f51?auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?auto=format&fit=crop&q=80',
        ]),
        const SizedBox(height: 40),
        _buildPopularTopicSection('Easy drawings', [
          'https://images.unsplash.com/photo-1513364776144-60967b0f800f?auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1547826039-bfc35e0f1ea8?auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1582201942988-13e60e4556ee?auto=format&fit=crop&q=80',
        ]),
        const SizedBox(height: 40),
        _buildPopularTopicSection('Birthday cake', [
          'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1588195538326-c5b1e9f80a1b?auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1535141192574-5d4897c12636?auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1464349095431-e9a21285b5f3?auto=format&fit=crop&q=80',
        ]),
        const SizedBox(height: 40),
        _buildPopularTopicSection('Matching pfp', [
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80',
        ]),
      ],
    );
  }

  Widget _buildPopularTopicSection(String topic, List<String> images) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                topic,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const Icon(Icons.search, size: 24),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 180,
            child: Row(
              children: List.generate(images.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index == images.length - 1 ? 0 : 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        images[index],
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExploreFeaturedBoards() {
    return SizedBox(
      height: 260,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return _buildBoardPreviewCard(index);
        },
      ),
    );
  }

  Widget _buildBoardPreviewCard(int index) {
    final List<Map<String, String>> boards = [
      {
        'title': 'Vamp Romantic 🦇',
        'creator': 'Nessa Barrett ✅ + 2',
        'pins': '54 Pins · 4d',
        'mainImage': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80',
        'sideImage1': 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&q=80',
        'sideImage2': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80',
      },
      {
        'title': 'DIY birthday greetings',
        'creator': 'Collages ✅',
        'pins': '49 Pins · 6mo',
        'mainImage': 'https://images.unsplash.com/photo-1530103043960-ef38714abb15?auto=format&fit=crop&q=80',
        'sideImage1': 'https://images.unsplash.com/photo-1513201099705-a9746e1e201f?auto=format&fit=crop&q=80',
        'sideImage2': 'https://images.unsplash.com/photo-1454944338482-a69bb95894af?auto=format&fit=crop&q=80',
      },
      {
        'title': 'Interior Design',
        'creator': 'HomeStyle',
        'pins': '120 Pins · 1d',
        'mainImage': 'https://images.unsplash.com/photo-1616489953149-75ec07aa2221?auto=format&fit=crop&q=80',
        'sideImage1': 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80',
        'sideImage2': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?auto=format&fit=crop&q=80',
      },
      {
        'title': 'Aesthetic Art',
        'creator': 'ArtistHub',
        'pins': '30 Pins · 1w',
        'mainImage': 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?auto=format&fit=crop&q=80',
        'sideImage1': 'https://images.unsplash.com/photo-1547826039-bfc35e0f1ea8?auto=format&fit=crop&q=80',
        'sideImage2': 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?auto=format&fit=crop&q=80',
      },
    ];

    final board = boards[index % boards.length];

    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Image.network(
                    board['mainImage']!,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Column(
                    children: [
                      Image.network(
                        board['sideImage1']!,
                        height: 79,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 2),
                      Image.network(
                        board['sideImage2']!,
                        height: 79,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            board['title']!,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  board['creator']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            board['pins']!,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(SearchState searchState) {
    final columns = Responsive.gridColumns(context);
    final spacing = Responsive.gridSpacing(context);

    if (searchState.isLoading) {
      return const ShimmerGrid();
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(spacing),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childCount: searchState.results.length,
            itemBuilder: (context, index) {
              final pin = searchState.results[index];
              return PinCard(
                pin: pin,
                heroTag: 'search_pin_${pin.id}',
                onTap: () => context.push('/pin/${pin.id}'),
                onSave: () =>
                    ref.read(boardProvider.notifier).quickSave(pin),
              );
            },
          ),
        ),
        if (searchState.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: ShimmerGrid(itemCount: 4, isInline: true),
            ),
          ),
      ],
    );
  }

  static const _categories = [
    'Fashion',
    'Food',
    'Home',
    'Art',
    'Travel',
    'Nature',
    'DIY',
    'Fitness',
    'Beauty',
    'Design',
  ];
}
