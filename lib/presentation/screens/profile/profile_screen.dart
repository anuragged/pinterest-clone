import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../providers/board_provider.dart';
import '../../widgets/board_card.dart';
import '../../widgets/pinterest_refresh_indicator.dart';

/// Profile screen matching Figma design with avatar, stats, Created/Saved tabs.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final auth = ref.watch(authProvider);
    final boardState = ref.watch(boardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: PinterestRefreshIndicator(
          onRefresh: () async {
            await ref.read(boardProvider.notifier).refresh();
          },
          child: NestedScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                floating: true,
                pinned: false,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.share_outlined,
                    color: isDark ? Colors.white : PinColors.iconDefault,
                    size: 22,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => context.push('/settings'),
                    icon: Icon(
                      Icons.settings_outlined,
                      color: isDark ? Colors.white : PinColors.iconDefault,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: _buildProfileHeader(auth, isDark),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor:
                        isDark ? Colors.white : PinColors.textPrimary,
                    indicatorWeight: 3,
                    labelColor:
                        isDark ? Colors.white : PinColors.textPrimary,
                    unselectedLabelColor: isDark
                        ? Colors.white54
                        : PinColors.textSecondary,
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(text: 'Created'),
                      Tab(text: 'Saved'),
                    ],
                  ),
                  isDark,
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildCreatedTab(isDark),
              _buildSavedTab(boardState, isDark),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AuthState auth, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PinDimensions.paddingXXL,
        vertical: PinDimensions.paddingL,
      ),
      child: Column(
        children: [
          // Avatar with photo
          Stack(
            children: [
              CircleAvatar(
                radius: PinDimensions.avatarXL / 2,
                backgroundColor: PinColors.pinterestRed,
                backgroundImage: auth.isAuthenticated && auth.avatarUrl != null
                    ? NetworkImage(auth.avatarUrl!)
                    : null,
                child: auth.avatarUrl == null
                    ? Text(
                        auth.isAuthenticated
                            ? (auth.displayName ?? 'G')[0].toUpperCase()
                            : 'G',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: PinColors.white,
                        ),
                      )
                    : null,
              ),
              // Edit icon
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF333333) : PinColors.backgroundWash,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF111111) : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 14,
                    color: isDark ? Colors.white : PinColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            auth.isAuthenticated ? (auth.displayName ?? 'Guest') : 'Guest',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : PinColors.textPrimary,
            ),
          ),

          // Username
          Text(
            auth.isAuthenticated
                ? '@${(auth.displayName ?? "guest").toLowerCase().replaceAll(" ", "")}'
                : '@guest',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : PinColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat('0', 'followers', isDark),
              const SizedBox(width: 8),
              Text('·',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : PinColors.textSecondary,
                    fontSize: 16,
                  )),
              const SizedBox(width: 8),
              _buildStat('0', 'following', isDark),
            ],
          ),
          const SizedBox(height: 16),

          // Actions
          if (!auth.isAuthenticated)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).signIn(
                        displayName: 'Anurag',
                        email: 'anurag@example.com',
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PinColors.pinterestRed,
                  foregroundColor: PinColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(PinDimensions.buttonRadius),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Sign in',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Edit profile button
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        isDark ? Colors.white : PinColors.textPrimary,
                    side: BorderSide(
                      color: isDark
                          ? Colors.white24
                          : PinColors.borderDefault,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          PinDimensions.buttonRadius),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'Edit profile',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                // Share profile
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? Colors.white24
                          : PinColors.borderDefault,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.upload_outlined,
                      size: 18,
                      color: isDark ? Colors.white : PinColors.iconDefault,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStat(String count, String label, bool isDark) {
    return Text(
      '$count $label',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white54 : PinColors.textSecondary,
      ),
    );
  }

  Widget _buildCreatedTab(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.push_pin_outlined,
            size: 48,
            color: isDark ? Colors.white38 : PinColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'No pins created yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : PinColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pins you create will show up here',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : PinColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: PinColors.pinterestRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Create Pin',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedTab(BoardState boardState, bool isDark) {
    if (boardState.boards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 48,
              color: isDark ? Colors.white38 : PinColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'No boards yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : PinColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Save pins to boards to organize your ideas',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : PinColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final columns = Responsive.isMobile(context) ? 2 : 3;

    return Column(
      children: [
        // Sort/filter row
        Padding(
          padding: const EdgeInsets.all(PinDimensions.paddingL),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF333333)
                      : PinColors.backgroundWash,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sort,
                      size: 16,
                      color: isDark
                          ? Colors.white
                          : PinColors.textPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'A-Z',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white
                            : PinColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(
                Icons.add,
                color: isDark ? Colors.white : PinColors.iconDefault,
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: PinDimensions.paddingL),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: boardState.boards.length,
            itemBuilder: (context, index) {
              final board = boardState.boards[index];
              return BoardCard(
                board: board,
                onTap: () => context.push('/board/${board.id}'),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDark;

  _TabBarDelegate(this.tabBar, this.isDark);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? const Color(0xFF111111) : PinColors.backgroundPrimary,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      isDark != oldDelegate.isDark;
}
