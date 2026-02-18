import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/haptics.dart';

/// Notifications/Inbox screen matching user's specific image request.
/// Shows Inbox title, Messages list, and Updates empty state with bottle illustration.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PinDimensions.paddingL,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Inbox',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : PinColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: isDark ? Colors.white : PinColors.textPrimary,
                        size: 26,
                      ),
                      onPressed: () => Haptics.light(),
                    ),
                  ],
                ),
              ),

              // ── Messages Section ──
              Padding(
                padding: const EdgeInsets.fromLTRB(PinDimensions.paddingL, 16, PinDimensions.paddingL, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Messages',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : PinColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Haptics.light(),
                      child: Row(
                        children: [
                          Text(
                            'See all',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : PinColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: isDark ? Colors.white : PinColors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Pinterest India Message ──
              _buildInboxItem(
                context: context,
                isDark: isDark,
                icon: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: 'Pinterest India',
                subtitle: 'Sent a Pin',
                trailing: '4y',
                onTap: () {
                  Haptics.medium();
                  context.push('/chat/pinterest_india');
                },
              ),

              // ── Invite Friends Item ──
              _buildInboxItem(
                context: context,
                isDark: isDark,
                icon: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2B2B2B) : const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person_add_outlined,
                      color: isDark ? Colors.white : PinColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
                title: 'Invite your friends',
                subtitle: 'Connect to start chatting',
                onTap: () => Haptics.light(),
              ),

              const SizedBox(height: 32),

              // ── Updates Section ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: PinDimensions.paddingL),
                child: Text(
                  'Updates',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : PinColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // ── Empty State Illustration ──
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/icons/bottle.png',
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 48),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        'Updates show activity on your Pins and boards and give you tips on topics to explore. They\'ll be here soon.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : PinColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInboxItem({
    required BuildContext context,
    required bool isDark,
    required Widget icon,
    required String title,
    required String subtitle,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PinDimensions.paddingL,
          vertical: 12,
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : PinColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : PinColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white38 : PinColors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
