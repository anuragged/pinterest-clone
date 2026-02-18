import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/haptics.dart';
import '../../providers/auth_provider.dart';

class ChatScreen extends ConsumerWidget {
  final String chatId;

  const ChatScreen({
    super.key,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : PinColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF000000) : PinColors.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: isDark ? Colors.white : PinColors.textPrimary,
            size: 32,
          ),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Pinterest India',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : PinColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_horiz,
              color: isDark ? Colors.white : PinColors.textPrimary,
            ),
            onPressed: () => Haptics.light(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  
                  // Stacked Avatars
                  _buildStackedAvatars(auth, isDark),
                  
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Pinterest India',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'This could be the beginning of something\ngood',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.3,
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Date Divider
                  const Text(
                    'Apr 26, 8:48',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white38,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Messages
                  _buildChatMessage(
                    'Hey Anurag. Say 👋 to your\nPinterest Inbox!',
                    isDark,
                  ),
                  _buildChatMessage(
                    'You can share ideas and\nimages with your friends right\nhere on Pinterest.',
                    isDark,
                  ),
                  _buildChatMessage(
                    'First, make sure you can find\nyour friends by syncing your\ncontacts (in your Privacy &\nData settings).',
                    isDark,
                  ),
                  _buildChatMessage(
                    'Then, just click the share icon\nnext to any Pin to send it in a\nmessage. Tap the Pin below\nto try it for yourself!',
                    isDark,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Replies
                  _buildQuickReplies(isDark),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Bottom Bar
          _buildBottomBar(isDark),
        ],
      ),
    );
  }

  Widget _buildStackedAvatars(AuthState auth, bool isDark) {
    return SizedBox(
      width: 130,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pinterest Logo Avatar
          Positioned(
            left: 20,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: PinColors.pinterestRed,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 4),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // User Avatar
          Positioned(
            right: 20,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: auth.avatarUrl != null
                    ? Image.network(auth.avatarUrl!, fit: BoxFit.cover)
                    : const Center(
                        child: Icon(Icons.person, color: Colors.white38, size: 40),
                      ),
              ),
            ),
          ),
          
          // Floating Icons
          Positioned(
            top: 0,
            left: 10,
            child: _buildFloatingBubble(Icons.chat_bubble_rounded, isDark),
          ),
          Positioned(
            top: 0,
            right: 10,
            child: _buildFloatingBubble(Icons.back_hand_rounded, isDark, color: Colors.orangeAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBubble(IconData icon, bool isDark, {Color color = Colors.white}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildChatMessage(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12, width: 0.5),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickReplies(bool isDark) {
    final replies = [
      {'text': 'Love it!', 'emoji': '❤️'},
      {'text': 'Let\'s do it!', 'emoji': '👍'},
      {'text': 'Hmm...', 'emoji': null},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: replies.map((reply) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2B2B2B),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                   Text(
                    reply['text'] as String,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  if (reply['emoji'] != null) ...[
                    const SizedBox(width: 4),
                    Text(reply['emoji'] as String),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white10),
              ),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Type a message...',
                  style: TextStyle(color: Colors.white38, fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 28),
        ],
      ),
    );
  }
}
