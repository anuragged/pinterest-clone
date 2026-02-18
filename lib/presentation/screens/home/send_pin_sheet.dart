import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/haptics.dart';

/// "Send on Pinterest" share sheet — Figma Section 2: Home
/// Shows recent contacts and social share options.
class SendPinSheet extends StatefulWidget {
  final String pinImageUrl;
  final String pinTitle;

  const SendPinSheet({
    super.key,
    required this.pinImageUrl,
    required this.pinTitle,
  });

  @override
  State<SendPinSheet> createState() => _SendPinSheetState();
}

class _SendPinSheetState extends State<SendPinSheet> {
  final TextEditingController _searchController = TextEditingController();
  final List<_Contact> _recentContacts = [
    _Contact('Alex', 'A', const Color(0xFF4A90D9)),
    _Contact('Dana', 'D', const Color(0xFFE91E63)),
    _Contact('Sam', 'S', const Color(0xFF4CAF50)),
    _Contact('Chris', 'C', const Color(0xFFFF9800)),
    _Contact('Taylor', 'T', const Color(0xFF9C27B0)),
    _Contact('Morgan', 'M', const Color(0xFF00BCD4)),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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

          // Title
          Padding(
            padding: const EdgeInsets.all(PinDimensions.paddingL),
            child: Text(
              'Send on Pinterest',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : PinColors.textPrimary,
              ),
            ),
          ),

          // Pin preview
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PinDimensions.paddingXXL,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.pinImageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 48,
                      height: 48,
                      color: PinColors.shimmerBase,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.pinTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : PinColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PinDimensions.paddingXXL,
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
                style: TextStyle(
                  color: isDark ? Colors.white : PinColors.textPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by name or email',
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
          const SizedBox(height: 20),

          // Recent contacts
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PinDimensions.paddingXXL,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : PinColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Contact avatars row
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: PinDimensions.paddingXXL,
              ),
              itemCount: _recentContacts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final contact = _recentContacts[index];
                return GestureDetector(
                  onTap: () {
                    Haptics.light();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sent to ${contact.name}'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: contact.color,
                        child: Text(
                          contact.initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 56,
                        child: Text(
                          contact.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.white70
                                : PinColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Social share options
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PinDimensions.paddingXXL,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Share to',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : PinColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: PinDimensions.paddingXXL,
              ),
              children: [
                _buildSocialOption(
                  icon: Icons.copy,
                  label: 'Copy link',
                  color: isDark ? const Color(0xFF444444) : PinColors.textPrimary,
                  isDark: isDark,
                  onTap: () => _shareAction(context, 'Link copied'),
                ),
                const SizedBox(width: 16),
                _buildSocialOption(
                  icon: Icons.chat_bubble_outline,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  isDark: isDark,
                  onTap: () => _shareAction(context, 'Opening WhatsApp'),
                ),
                const SizedBox(width: 16),
                _buildSocialOption(
                  icon: Icons.message_outlined,
                  label: 'Messages',
                  color: const Color(0xFF34C759),
                  isDark: isDark,
                  onTap: () => _shareAction(context, 'Opening Messages'),
                ),
                const SizedBox(width: 16),
                _buildSocialOption(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  color: const Color(0xFF1877F2),
                  isDark: isDark,
                  onTap: () => _shareAction(context, 'Opening Facebook'),
                ),
                const SizedBox(width: 16),
                _buildSocialOption(
                  icon: Icons.more_horiz,
                  label: 'More',
                  color: isDark ? const Color(0xFF444444) : PinColors.backgroundWash,
                  isDark: isDark,
                  onTap: () => _shareAction(context, 'Share options'),
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildSocialOption({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 60,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : PinColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareAction(BuildContext context, String message) {
    Haptics.light();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _Contact {
  final String name;
  final String initial;
  final Color color;
  const _Contact(this.name, this.initial, this.color);
}
