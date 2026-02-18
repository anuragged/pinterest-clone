import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/responsive.dart';

/// Shimmer placeholder grid that mirrors the masonry layout structure.
/// Shown during initial feed load and at the bottom during infinite scroll.
class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final bool isInline; // Whether rendered inline (bottom of list) vs full page

  const ShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.isInline = false,
  });

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.gridColumns(context);
    final spacing = Responsive.gridSpacing(context);

    final baseColor = Theme.of(context).brightness == Brightness.light
        ? PinColors.shimmerBase
        : const Color(0xFF2B2B2B);
    final highlightColor = Theme.of(context).brightness == Brightness.light
        ? PinColors.shimmerHighlight
        : const Color(0xFF3B3B3B);

    if (isInline) {
      return _buildInlineShimmer(columns, spacing, baseColor, highlightColor);
    }

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(itemCount, (index) {
            final height = _shimmerHeight(index);
            final width = (MediaQuery.sizeOf(context).width -
                    spacing * (columns + 1)) /
                columns;
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(PinDimensions.cardRadius),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInlineShimmer(int columns, double spacing, Color baseColor, Color highlightColor) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(columns, (col) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                child: Column(
                  children: List.generate(2, (row) {
                    final height = _shimmerHeight(col * 2 + row);
                    return Padding(
                      padding: EdgeInsets.only(bottom: spacing),
                      child: Container(
                        width: double.infinity,
                        height: height,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius:
                              BorderRadius.circular(PinDimensions.cardRadius),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  double _shimmerHeight(int index) {
    // Vary heights to mimic masonry layout
    const heights = [200.0, 260.0, 180.0, 300.0, 220.0, 240.0, 190.0, 280.0];
    return heights[index % heights.length];
  }
}

/// Single shimmer pin card placeholder.
class ShimmerPinCard extends StatelessWidget {
  final double height;

  const ShimmerPinCard({super.key, this.height = 200});

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).brightness == Brightness.light
        ? PinColors.shimmerBase
        : const Color(0xFF2B2B2B);
    final highlightColor = Theme.of(context).brightness == Brightness.light
        ? PinColors.shimmerHighlight
        : const Color(0xFF3B3B3B);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(PinDimensions.cardRadius),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 100,
            height: 12,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 10,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
