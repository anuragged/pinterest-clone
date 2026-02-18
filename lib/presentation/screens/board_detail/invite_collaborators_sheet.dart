import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/haptics.dart';

/// "Invite collaborators" sheet — Figma Section 3: Bookmark & Collections
/// Allows searching and adding people to a board.
class InviteCollaboratorsSheet extends StatefulWidget {
  final String boardName;

  const InviteCollaboratorsSheet({
    super.key,
    required this.boardName,
  });

  @override
  State<InviteCollaboratorsSheet> createState() => _InviteCollaboratorsSheetState();
}

class _InviteCollaboratorsSheetState extends State<InviteCollaboratorsSheet> {
  final TextEditingController _searchController = TextEditingController();
  final List<_UserSuggestion> _suggestions = [
    _UserSuggestion('Pinterest User', '@pinterest', null, const Color(0xFFE60023)),
    _UserSuggestion('Creative Mind', '@creative', null, const Color(0xFF4CAF50)),
    _UserSuggestion('Design Enthusiast', '@designer', null, const Color(0xFF2196F3)),
    _UserSuggestion('Art Lover', '@artlover', null, const Color(0xFFFF9800)),
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
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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

          // Header
          Padding(
            padding: const EdgeInsets.all(PinDimensions.paddingL),
            child: Text(
              'Invite collaborators',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : PinColors.textPrimary,
              ),
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF333333) : PinColors.backgroundWash,
                borderRadius: BorderRadius.circular(PinDimensions.buttonRadius),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(
                  color: isDark ? Colors.white : PinColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by name or email',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : PinColors.textSecondary,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.white38 : PinColors.iconSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Copy link option
          ListTile(
            onTap: () {
              Haptics.light();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invite link copied')),
              );
            },
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF333333) : PinColors.backgroundWash,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.link,
                color: isDark ? Colors.white70 : PinColors.textPrimary,
              ),
            ),
            title: Text(
              'Copy link',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : PinColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Anyone with the link can join the board',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white38 : PinColors.textSecondary,
              ),
            ),
          ),

          const Divider(indent: 80),

          // Suggestions
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'SUGGESTED',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white54 : PinColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              itemBuilder: (context, index) {
                final user = _suggestions[index];
                return ListTile(
                  onTap: () {
                    Haptics.medium();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invite sent to ${user.name}')),
                    );
                  },
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: user.color,
                    backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                    child: user.avatarUrl == null
                        ? Text(
                            user.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : PinColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    user.username,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white38 : PinColors.textSecondary,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: PinColors.pinterestRed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Invite',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserSuggestion {
  final String name;
  final String username;
  final String? avatarUrl;
  final Color color;
  const _UserSuggestion(this.name, this.username, this.avatarUrl, this.color);
}
