import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/haptics.dart';
import '../../domain/entities/pin.dart';

/// Pinterest pin card redesigned to match Figma precisely.
/// Features:
/// - Highly rounded corners (32.0 radius)
/// - Top-left badges for multi-images/boards
/// - Footer with avatar, name, and "more" icon
/// - Reaction stat line (heart + count)
class PinCard extends StatefulWidget {
  final Pin pin;
  final VoidCallback onTap;
  final VoidCallback onSave;
  final Function(Offset)? onLongPress;
  final String heroTag;

  const PinCard({
    super.key,
    required this.pin,
    required this.onTap,
    required this.onSave,
    this.onLongPress,
    required this.heroTag,
  });

  @override
  State<PinCard> createState() => _PinCardState();
}

class _PinCardState extends State<PinCard> {
  bool _isPressed = false;

  Color _parseAvgColor() {
    try {
      final hex = widget.pin.avgColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return PinColors.shimmerBase;
    }
  }

  @override
  Widget build(BuildContext context) {
    final avgColor = _parseAvgColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Most cards in Pinterest home feed are clean images with just an optional badge
    // and a "..." menu at the bottom.
    final bool showFullFooter = widget.pin.id == 'pin_1'; // Just show for the first one as requested

    return GestureDetector(
      onTap: () {
        Haptics.light();
        widget.onTap();
      },
      onLongPressStart: (details) {
        Haptics.medium();
        widget.onLongPress?.call(details.globalPosition);
      },
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Image with Badge ──
            Stack(
              children: [
                _buildImage(avgColor),
                // Small "..." icon at bottom right of image
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Icon(
                    Icons.more_horiz,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),

            if (showFullFooter) ...[
              const SizedBox(height: 8),

              // ── Creator Footer (Avatar + Name) ──
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://i.pravatar.cc/100?u=${widget.pin.photographerId}',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.pin.photographerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : PinColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              // ── Stats (Heart + Count) ──
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 2),
                child: Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      size: 14,
                      color: Color(0xFFFF5A5F),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(widget.pin.saves / 100).toStringAsFixed(1)}k',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white60 : PinColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImage(Color avgColor) {
    // Determine if we show a badge (pseudo-random for demo)
    final showBadge = widget.pin.id.hashCode % 3 == 0;
    final badgeCount = 2 + (widget.pin.id.length % 5);

    return Hero(
      tag: widget.heroTag,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(PinDimensions.cardRadiusLarge),
            child: AspectRatio(
              aspectRatio: widget.pin.aspectRatio.clamp(0.6, 1.8),
              child: CachedNetworkImage(
                imageUrl: widget.pin.thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: avgColor.withValues(alpha: 0.3),
                  highlightColor: avgColor.withValues(alpha: 0.1),
                  child: Container(color: avgColor),
                ),
                errorWidget: (context, url, error) => Container(
                  color: avgColor.withValues(alpha: 0.3),
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
          ),
          if (showBadge)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.copy, size: 14, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
