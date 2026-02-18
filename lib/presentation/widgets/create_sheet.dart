import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/haptics.dart';

class CreateSheet extends StatelessWidget {
  const CreateSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF2B2B2B) : Colors.white;
    final iconBoxColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05);
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: textColor, size: 28),
                ),
              ),
              Text(
                'Start creating now',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _createOption(
                icon: Icons.push_pin_rounded,
                label: 'Pin',
                color: iconBoxColor,
                textColor: textColor,
                onTap: () {
                  Haptics.medium();
                  Navigator.pop(context);
                },
              ),
              _createOption(
                icon: Icons.content_cut_rounded, // Best match for the scissor/collage feel
                label: 'Collage',
                color: iconBoxColor,
                textColor: textColor,
                onTap: () {
                  Haptics.medium();
                  Navigator.pop(context);
                },
              ),
              _createOption(
                icon: Icons.grid_view_rounded,
                label: 'Board',
                color: iconBoxColor,
                textColor: textColor,
                onTap: () {
                  Haptics.medium();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _createOption({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: textColor, size: 32),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
