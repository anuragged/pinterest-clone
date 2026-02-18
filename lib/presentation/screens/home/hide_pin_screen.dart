import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/haptics.dart';

/// "Why are you hiding this Pin?" screen — Figma Section 2: Home
/// Shown after long-press → Hide on a pin card.
class HidePinScreen extends StatelessWidget {
  final String pinImageUrl;
  final String pinTitle;
  final VoidCallback onDone;

  const HidePinScreen({
    super.key,
    required this.pinImageUrl,
    required this.pinTitle,
    required this.onDone,
  });

  static const _reasons = [
    {'icon': Icons.not_interested, 'text': 'Not relevant to me'},
    {'icon': Icons.remove_red_eye_outlined, 'text': 'I\'ve already seen this'},
    {'icon': Icons.content_copy, 'text': 'It looks like spam'},
    {'icon': Icons.warning_amber_rounded, 'text': 'Nudity or pornography'},
    {'icon': Icons.dangerous_outlined, 'text': 'Hateful activities'},
    {'icon': Icons.shield_outlined, 'text': 'Misinformation'},
    {'icon': Icons.report_outlined, 'text': 'Harassment or privacy violation'},
    {'icon': Icons.more_horiz, 'text': 'Other'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: isDark ? Colors.white : PinColors.textPrimary,
          ),
        ),
        title: Text(
          'Hide Pin',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : PinColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(PinDimensions.paddingXXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pin preview
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    pinImageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 64,
                      height: 64,
                      color: PinColors.shimmerBase,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pinTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : PinColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: PinColors.pinterestRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Hidden',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: PinColors.pinterestRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Why are you hiding this Pin?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : PinColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your feedback helps us improve your home feed',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : PinColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Reasons list
            ...List.generate(_reasons.length, (index) {
              final reason = _reasons[index];
              return _ReasonTile(
                icon: reason['icon'] as IconData,
                text: reason['text'] as String,
                isDark: isDark,
                onTap: () {
                  Haptics.medium();
                  onDone();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Thanks for your feedback'),
                      backgroundColor: isDark
                          ? const Color(0xFF333333)
                          : PinColors.textPrimary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              );
            }),

            const SizedBox(height: 16),

            // Undo button
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Undo hiding',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : PinColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  final VoidCallback onTap;

  const _ReasonTile({
    required this.icon,
    required this.text,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isDark ? Colors.white70 : PinColors.textPrimary,
          size: 22,
        ),
        title: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : PinColors.textPrimary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? Colors.white38 : PinColors.iconSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
