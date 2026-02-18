import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/utils/haptics.dart';

/// Pinterest-style radial long-press menu.
/// When user long-presses, this overlay appears at the touch point.
/// Buttons are arranged in a radial pattern.
class PinActionMenu extends StatefulWidget {
  final String pinTitle;
  final String pinImageUrl;
  final Offset position;
  final VoidCallback onSave;
  final VoidCallback onHide;
  final VoidCallback onShare;
  final VoidCallback onReport;

  const PinActionMenu({
    super.key,
    required this.pinTitle,
    required this.pinImageUrl,
    required this.position,
    required this.onSave,
    required this.onHide,
    required this.onShare,
    required this.onReport,
  });

  @override
  State<PinActionMenu> createState() => _PinActionMenuState();
}

class _PinActionMenuState extends State<PinActionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _hoveredIndex = -1; // -1: none, 0: save, 1: hide, 2: share, 3: report

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateHover(Offset globalPosition, double safeX, double safeY, double secondaryRadius) {
    // Buttons are positioned relative to the dialog/screen
    final List<Offset> positions = [
      Offset(safeX, safeY), // Save (center)
      _calcOffset(safeX, safeY, -50, secondaryRadius), // Hide
      _calcOffset(safeX, safeY, 15, secondaryRadius), // Share
      _calcOffset(safeX, safeY, 80, secondaryRadius), // Send
    ];

    int newHover = -1;
    double snapDistance = 60.0; // Responsive threshold for selection

    for (int i = 0; i < positions.length; i++) {
        final double dist = (globalPosition - positions[i]).distance;
        if (dist < snapDistance) {
            newHover = i;
            break; 
        }
    }

    if (newHover != _hoveredIndex) {
      setState(() => _hoveredIndex = newHover);
      if (newHover != -1) Haptics.selection();
    }
  }

  Offset _calcOffset(double centerX, double centerY, double angle, double radius) {
    final double radian = angle * math.pi / 180;
    return Offset(
       centerX + (math.cos(radian) * radius),
       centerY + (math.sin(radian) * radius)
    );
  }

  void _triggerSelectedAction() {
    if (_hoveredIndex == 0) widget.onSave();
    if (_hoveredIndex == 1) widget.onHide();
    if (_hoveredIndex == 2) widget.onShare();
    if (_hoveredIndex == 3) widget.onReport();
    
    if (mounted) {
       Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double safetyMargin = 100.0;
    
    final double safeX = widget.position.dx.clamp(safetyMargin, size.width - safetyMargin);
    final double safeY = widget.position.dy.clamp(safetyMargin, size.height - safetyMargin);
    const double secondaryRadius = 72.0;

    return Listener(
      onPointerMove: (event) => _updateHover(event.position, safeX, safeY, secondaryRadius),
      onPointerUp: (event) => _triggerSelectedAction(),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Premium Blur Background (closes on tap outside)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 5.0),
                  duration: const Duration(milliseconds: 200),
                  builder: (context, value, child) {
                    return ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(sigmaX: value, sigmaY: value),
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Interaction Cluster
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final double scale = _animation.value;
                  final double opacity = _animation.value.clamp(0.0, 1.0);
                  
                  return Stack(
                    children: [
                      _buildButton(
                        centerX: safeX,
                        centerY: safeY,
                        angle: 0, 
                        radius: 0,
                        icon: Icons.push_pin,
                        isSelected: _hoveredIndex == 0,
                        scale: scale,
                        opacity: opacity,
                      ),
                      _buildButton(
                        centerX: safeX,
                        centerY: safeY,
                        angle: -50,
                        radius: secondaryRadius,
                        icon: Icons.visibility_off,
                        isSelected: _hoveredIndex == 1,
                        scale: scale,
                        opacity: opacity,
                      ),
                      _buildButton(
                        centerX: safeX,
                        centerY: safeY,
                        angle: 15,
                        radius: secondaryRadius,
                        icon: Icons.ios_share,
                        isSelected: _hoveredIndex == 2,
                        scale: scale,
                        opacity: opacity,
                      ),
                      _buildButton(
                        centerX: safeX,
                        centerY: safeY,
                        angle: 80,
                        radius: secondaryRadius,
                        icon: Icons.textsms,
                        isSelected: _hoveredIndex == 3,
                        scale: scale,
                        opacity: opacity,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required double centerX,
    required double centerY,
    required double angle,
    required double radius,
    required IconData icon,
    required bool isSelected,
    required double scale,
    required double opacity,
  }) {
    final double radian = angle * math.pi / 180;
    final double x = centerX + (math.cos(radian) * radius * scale);
    final double y = centerY + (math.sin(radian) * radius * scale);

    final double size = isSelected ? 80.0 : 56.0;
    final Color bgColor = isSelected ? const Color(0xFFE60023) : Colors.white;
    final Color iconColor = isSelected ? Colors.white : Colors.black;

    return Positioned(
      left: x - (size / 2),
      top: y - (size / 2),
      child: Opacity(
        opacity: opacity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              color: iconColor,
              size: size * 0.45,
            ),
          ),
        ),
      ),
    );
  }
}
