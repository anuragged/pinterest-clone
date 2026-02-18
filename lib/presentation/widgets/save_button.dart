import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/haptics.dart';

/// Pinterest-style save button with micro scale-up bounce animation.
/// Uses easeOutCubic for all animations.
class SaveButton extends StatefulWidget {
  final bool isSaved;
  final VoidCallback onTap;
  final bool compact;

  const SaveButton({
    super.key,
    required this.isSaved,
    required this.onTap,
    this.compact = true,
  });

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: PinDimensions.animDurationNormal),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    Haptics.medium();
    _controller.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: widget.isSaved 
            ? (Theme.of(context).brightness == Brightness.light ? PinColors.textPrimary : const Color(0xFF333333))
            : PinColors.pinterestRed,
        borderRadius: BorderRadius.circular(
          widget.compact
              ? PinDimensions.saveButtonRadius
              : PinDimensions.buttonRadius,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(
            widget.compact
                ? PinDimensions.saveButtonRadius
                : PinDimensions.buttonRadius,
          ),
          onTap: _handleTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.compact ? 12 : 20,
              vertical: widget.compact ? 6 : 12,
            ),
            child: Text(
              widget.isSaved ? 'Saved' : 'Save',
              style: TextStyle(
                color: PinColors.textInverse,
                fontSize: widget.compact ? 13 : 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
