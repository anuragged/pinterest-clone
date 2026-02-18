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
import '../../providers/discovery_provider.dart';
import '../../../domain/entities/pin.dart';
import 'package:cached_network_image/cached_network_image.dart';

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


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchProvider.notifier).initialize();
      ref.read(discoveryProvider.notifier).loadDiscovery();
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
    final discoveryState = ref.watch(discoveryProvider);

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
                  await ref.read(discoveryProvider.notifier).loadDiscovery();
                  await ref.read(searchProvider.notifier).refresh();
                },
                child: searchState.isSearching
                    ? _buildSuggestionsAndHistory(searchState)
                    : searchState.results.isNotEmpty
                        ? _buildResults(searchState)
                        : _buildDiscovery(searchState, discoveryState),
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

  Widget _buildDiscovery(SearchState searchState, DiscoveryState discoveryState) {
    if (discoveryState.isLoading && discoveryState.ideasForYou.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: PinColors.pinterestRed));
    }

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
          _buildIdeasForYouGrid(discoveryState.ideasForYou),

          const SizedBox(height: 32),

          // ── Today's Inspiration (Carousel) ──
          _buildDiscoveryHeader('Today\'s Inspiration'),
          _buildTodayInspirationCarousel(discoveryState.todayInspiration),

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
          _buildExploreFeaturedBoards(discoveryState.featuredBoards),

          const SizedBox(height: 32),

          // ── Ideas from creators (Horizontal List) ──
          _buildDiscoveryHeader('Ideas from creators'),
          _buildIdeasFromCreators(discoveryState.creatorIdeas),

          const SizedBox(height: 32),

          // ── Shopping spotlight ──
          _buildDiscoveryHeader('Shopping spotlight'),
          if (discoveryState.spotlight.isNotEmpty)
            _buildSpotlightCard(
              'The take-care-of-yourself edit',
              discoveryState.spotlight.first.imageUrl,
            ),

          const SizedBox(height: 48),

          // ── Popular on Pinterest ──
          _buildPopularOnPinterest(discoveryState.popularTopics),
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

  Widget _buildIdeasForYouGrid(List<Pin> ideas) {
    final List<String> categories = [
      'Interior design',
      'Outfit ideas',
      'Cooking recipes',
      'Art inspiration',
      'Travel destinations',
      'DIY projects',
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
        itemCount: categories.length.clamp(0, ideas.length),
        itemBuilder: (context, index) {
          final catName = categories[index];
          final imgUrl = ideas[index].thumbnailUrl;
          return GestureDetector(
            onTap: () {
              Haptics.light();
              _textController.text = catName;
              _onSearch(catName);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: imgUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black54, Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      catName,
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

  Widget _buildTodayInspirationCarousel(List<Pin> inspiration) {
    if (inspiration.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 480,
      child: PageView.builder(
        itemCount: inspiration.length,
        controller: _pageController,
        onPageChanged: (idx) => _currentPage = idx,
        itemBuilder: (context, index) {
          final pin = inspiration[index];
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
                    CachedNetworkImage(
                      imageUrl: pin.imageUrl,
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
                    if (pin.title != null)
                      Center(
                        child: Text(
                          pin.title!.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Courier', // For that handwritten/stylized look
                            letterSpacing: 2.0,
                            shadows: [
                               BoxShadow(
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
                            pin.photographerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            pin.title ?? 'Aesthetic Pin',
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
                           inspiration.length,
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

  Widget _buildIdeasFromCreators(List<Pin> creators) {
    if (creators.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: creators.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final pin = creators[index];
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
                        image: CachedNetworkImageProvider(pin.imageUrl),
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
                          backgroundImage: NetworkImage('https://i.pravatar.cc/100?u=${pin.photographerId}'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                pin.photographerName,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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

  Widget _buildPopularOnPinterest(Map<String, List<Pin>> popularTopics) {
    if (popularTopics.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: popularTopics.entries.map((entry) {
        return Column(
           children: [
             _buildPopularTopicSection(entry.key, entry.value.map((p) => p.thumbnailUrl).toList()),
             const SizedBox(height: 40),
           ],
        );
      }).toList(),
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

  Widget _buildExploreFeaturedBoards(List<Pin> boards) {
    if (boards.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 260,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: boards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final pin = boards[index];
          // Use the pin for the main image and placeholders for others
          return _buildBoardPreviewCard(index, pin);
        },
      ),
    );
  }

  Widget _buildBoardPreviewCard(int index, Pin pin) {
    final List<Map<String, String>> boardsData = [
      {
        'title': 'Vamp Romantic 🦇',
        'creator': 'Creator ✅',
      },
      {
        'title': 'DIY birthday greetings',
        'creator': 'Collages ✅',
      },
      {
        'title': 'Interior Design',
        'creator': 'HomeStyle',
      },
      {
        'title': 'Aesthetic Art',
        'creator': 'ArtistHub',
      },
    ];

    final board = boardsData[index % boardsData.length];
    final imageUrl = pin.thumbnailUrl;
    final sideImage1 = pin.imageUrl;
    final sideImage2 = pin.mediumUrl ?? pin.imageUrl;

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
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl: sideImage1,
                        height: 79,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 2),
                      CachedNetworkImage(
                        imageUrl: sideImage2,
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
          const Text(
            '50+ Pins',
            style: TextStyle(
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
