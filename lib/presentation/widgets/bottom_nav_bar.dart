import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/haptics.dart';
import '../providers/auth_provider.dart';
import 'dart:io';

/// Bottom navigation bar using custom assets.
/// Fallback to Material Icons if assets are missing to avoid grey boxes.
class PinterestBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const PinterestBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: PinDimensions.bottomNavHeight + bottomPadding,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            label: 'Home',
            assetPath: 'assets/icons/home.png',
            fallbackIcon: Icons.home_filled,
            isSelected: currentIndex == 0,
            onTap: () => _handleTap(0),
          ),
          _NavItem(
            label: 'Search',
            assetPath: 'assets/icons/search.png',
            fallbackIcon: Icons.search,
            isSelected: currentIndex == 1,
            onTap: () => _handleTap(1),
          ),
          _NavItem(
            label: 'Create',
            assetPath: 'assets/icons/create.png',
            fallbackIcon: Icons.add,
            isSelected: currentIndex == 2,
            onTap: () => _handleTap(2),
          ),
          _NavItem(
            label: 'Inbox',
            assetPath: 'assets/icons/notifications.png',
            fallbackIcon: Icons.chat_bubble_rounded,
            isSelected: currentIndex == 3,
            onTap: () => _handleTap(3),
            hasNotification: true,
          ),
          _NavItem(
            label: 'Profile',
            assetPath: 'assets/icons/profile.png',
            customIcon: _buildProfileIcon(currentIndex == 4, isDark),
            isSelected: currentIndex == 4,
            onTap: () => _handleTap(4),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileIcon(bool isSelected, bool isDark) {
    return Consumer(
      builder: (context, ref, _) {
        final auth = ref.watch(authProvider);
        final activeColor = isDark ? Colors.white : Colors.black;
        final inactiveColor = isDark ? Colors.white38 : const Color(0xFF767676);

        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? activeColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: CircleAvatar(
              radius: 12,
              backgroundColor: inactiveColor.withValues(alpha: 0.1),
              backgroundImage: auth.avatarUrl != null ? NetworkImage(auth.avatarUrl!) : null,
              child: auth.avatarUrl == null
                  ? Icon(Icons.person, size: 16, color: inactiveColor)
                  : null,
            ),
          ),
        );
      },
    );
  }

  void _handleTap(int index) {
    Haptics.selection();
    onTap(index);
  }
}

class _NavItem extends StatefulWidget {
  final String label;
  final String? assetPath;
  final IconData? fallbackIcon;
  final Widget? customIcon;
  final bool isSelected;
  final bool hasNotification;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    this.assetPath,
    this.fallbackIcon,
    this.customIcon,
    required this.isSelected,
    this.hasNotification = false,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _assetExists = false;

  @override
  void initState() {
    super.initState();
    _checkAsset();
  }

  // Note: This is a simple check. In a real app we might use rootBundle
  // But since we want to handle the transition as the user adds files:
  void _checkAsset() {
    if (widget.assetPath != null) {
      // We'll try to load it and hide grey box if it fails
      // For now, let's just use the Image.asset errorBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? Colors.white : Colors.black;
    final inactiveColor = isDark ? Colors.white38 : const Color(0xFF767676);

    return Expanded(
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                if (widget.customIcon != null)
                  widget.customIcon!
                else if (widget.assetPath != null)
                  Image.asset(
                    widget.assetPath!,
                    width: 26,
                    height: 26,
                    color: widget.isSelected ? activeColor : inactiveColor,
                    colorBlendMode: BlendMode.srcIn,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to Material Icon if PNG is missing
                      return Icon(
                        widget.fallbackIcon,
                        size: 26,
                        color: widget.isSelected ? activeColor : inactiveColor,
                      );
                    },
                  )
                else
                  Icon(
                    widget.fallbackIcon,
                    size: 26,
                    color: widget.isSelected ? activeColor : inactiveColor,
                  ),
                if (widget.hasNotification)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF111111) : Colors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                color: widget.isSelected ? activeColor : inactiveColor,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
