import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../domain/entities/board.dart';

/// Board card with auto-generated cover from last 4 pins.
/// Displays board name, pin count, and secret indicator.
class BoardCard extends StatelessWidget {
  final Board board;
  final VoidCallback onTap;

  const BoardCard({
    super.key,
    required this.board,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cover mosaic ──
          ClipRRect(
            borderRadius:
                BorderRadius.circular(PinDimensions.boardCoverRadius),
            child: SizedBox(
              height: PinDimensions.boardCoverHeight,
              width: double.infinity,
              child: _buildCoverMosaic(),
            ),
          ),

          const SizedBox(height: 8),

          // ── Board name ──
          Row(
            children: [
              if (board.isSecret)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: PinColors.textSecondary,
                  ),
                ),
              Expanded(
                child: Text(
                  board.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),

          // ── Pin count ──
          Text(
            '${board.pinCount} Pin${board.pinCount != 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverMosaic() {
    final images = board.coverImages;

    if (images.isEmpty) {
      return Container(
        color: PinColors.backgroundWash,
        child: const Center(
          child: Icon(
            Icons.dashboard_outlined,
            size: 40,
            color: PinColors.textSecondary,
          ),
        ),
      );
    }

    if (images.length == 1) {
      return CachedNetworkImage(
        imageUrl: images[0],
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: PinColors.shimmerBase),
        errorWidget: (_, __, ___) =>
            Container(color: PinColors.backgroundWash),
      );
    }

    if (images.length == 2) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: CachedNetworkImage(
              imageUrl: images[0],
              fit: BoxFit.cover,
              height: PinDimensions.boardCoverHeight,
              placeholder: (_, __) => Container(color: PinColors.shimmerBase),
              errorWidget: (_, __, ___) =>
                  Container(color: PinColors.backgroundWash),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: CachedNetworkImage(
              imageUrl: images[1],
              fit: BoxFit.cover,
              height: PinDimensions.boardCoverHeight,
              placeholder: (_, __) => Container(color: PinColors.shimmerBase),
              errorWidget: (_, __, ___) =>
                  Container(color: PinColors.backgroundWash),
            ),
          ),
        ],
      );
    }

    // 3-4 images: Pinterest-style mosaic
    return Row(
      children: [
        // Left large image
        Expanded(
          flex: 2,
          child: CachedNetworkImage(
            imageUrl: images[0],
            fit: BoxFit.cover,
            height: PinDimensions.boardCoverHeight,
            placeholder: (_, __) => Container(color: PinColors.shimmerBase),
            errorWidget: (_, __, ___) =>
                Container(color: PinColors.backgroundWash),
          ),
        ),
        const SizedBox(width: 2),
        // Right column: 2-3 small images
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: images[1],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) =>
                      Container(color: PinColors.shimmerBase),
                  errorWidget: (_, __, ___) =>
                      Container(color: PinColors.backgroundWash),
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: images.length > 2 ? images[2] : images[1],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) =>
                      Container(color: PinColors.shimmerBase),
                  errorWidget: (_, __, ___) =>
                      Container(color: PinColors.backgroundWash),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
