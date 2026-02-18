import 'package:flutter/material.dart';

/// Small circular action button matching Figma "Action buttons" spec.
/// Used for Share, Delete, More, etc.
class PinActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;

  const PinActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.size = 40.0,
    this.iconSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? (isDark ? const Color(0xFF333333) : Colors.white),
          shape: BoxShape.circle,
          boxShadow: isDark ? null : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor ?? (isDark ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}
