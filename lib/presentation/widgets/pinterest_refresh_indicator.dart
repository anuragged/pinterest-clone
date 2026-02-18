import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/haptics.dart';

class PinterestRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const PinterestRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  State<PinterestRefreshIndicator> createState() => _PinterestRefreshIndicatorState();
}

class _PinterestRefreshIndicatorState extends State<PinterestRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pullController;
  late AnimationController _rotationController;
  late AnimationController _finishController;
  
  double _pullDistance = 0.0;
  bool _isRefreshing = false;
  
  static const double _threshold = 90.0;
  static const double _damping = 0.85;

  @override
  void initState() {
    super.initState();
    _pullController = AnimationController(vsync: this);
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _finishController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _pullController.dispose();
    _rotationController.dispose();
    _finishController.dispose();
    super.dispose();
  }

  bool _onNotification(ScrollNotification notification) {
    if (_isRefreshing || notification.metrics.axis != Axis.vertical) return false;

    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.pixels < 0) {
        // We are overscrolling at the top
        setState(() {
          _pullDistance = -notification.metrics.pixels;
          _pullController.value = math.min(1.0, _pullDistance / _threshold);
        });
      } else if (notification.metrics.pixels >= 0 && _pullDistance > 0) {
        setState(() {
          _pullDistance = 0;
          _pullController.value = 0;
        });
      }
    } else if (notification is ScrollEndNotification) {
      if (_pullDistance >= _threshold) {
        _startRefresh();
      } else if (_pullDistance > 0) {
        _cancelRefresh();
      }
    }
    return false;
  }

  void _startRefresh() async {
    setState(() => _isRefreshing = true);
    Haptics.medium();

    // Physics-based snap to locked state (locked height = 80)
    final spring = SpringDescription(
      mass: 1.0,
      stiffness: 180.0,
      damping: 15.0, // ≈0.75 damping ratio
    );
    
    // Snap to 80px for the "locked refresh state"
    final simulation = SpringSimulation(spring, _pullDistance, 80.0, 0);
    _pullController.animateWith(simulation);
    
    _rotationController.repeat();
    
    // Minimum duration of 1.5s to ensure user sees the high-fidelity animation
    final startTime = DateTime.now();
    await widget.onRefresh();
    final endTime = DateTime.now();
    final elapsed = endTime.difference(startTime);
    
    if (elapsed < const Duration(milliseconds: 1500)) {
      await Future.delayed(const Duration(milliseconds: 1500) - elapsed);
    }
    
    _finishRefresh();
  }

  void _cancelRefresh() {
    final spring = SpringDescription(
      mass: 1.0,
      stiffness: 200.0,
      damping: 20.0,
    );
    final simulation = SpringSimulation(spring, _pullDistance, 0, 0);
    _pullController.animateWith(simulation).then((_) {
      if (mounted) setState(() => _pullDistance = 0);
    });
  }

  void _finishRefresh() {
    // Rotation decelerates over 200ms
    _rotationController.stop();
    _finishController.forward(from: 0).then((_) {
        if (mounted) {
           setState(() {
              _isRefreshing = false;
              _pullDistance = 0;
           });
           _pullController.value = 0;
           _rotationController.value = 0;
           _finishController.reset();
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NotificationListener<ScrollNotification>(
      onNotification: _onNotification,
      child: Stack(
        children: [
          // Content
          AnimatedBuilder(
            animation: _pullController,
            builder: (context, child) {
              return child!;
            },
            child: widget.child,
          ),
          
          // Indicator Container
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: Listenable.merge([_pullController, _rotationController, _finishController]),
              builder: (context, child) {
                // Determine scale: 0.7 -> 1.0 during pull
                // Add a pulse effect during active refresh
                double scale = 0.7 + (0.3 * _pullController.value);
                
                if (_isRefreshing && !_finishController.isAnimating) {
                   // Active pulsing feedback (1.0 -> 1.1)
                   final pulse = (math.sin(DateTime.now().millisecondsSinceEpoch / 200) * 0.05) + 1.05;
                   scale = pulse;
                }

                if (_finishController.isAnimating) {
                    scale = 1.0 - _finishController.value; // Collapse to 0
                }
                
                double opacity = math.min(1.0, _pullController.value * 3);
                double yPos = _pullController.value * _threshold;
                
                // Rotation logic:
                // 1. Distance-driven during pull (θ = (dragDistance / 70) * 2π)
                // 2. Constant velocity during refresh
                // 3. Decelerates to 0 during finish
                
                double rotation;
                const double rotationStride = 70.0;
                
                if (!_isRefreshing) {
                   rotation = (_pullDistance / rotationStride) * 2 * math.pi;
                } else {
                   double baseRotation = _rotationController.value * 2 * math.pi;
                   double extraRotation = 0.0;
                   if (_finishController.isAnimating) {
                       extraRotation = (1.0 - math.pow(1.0 - _finishController.value, 2)) * (math.pi / 2);
                   }
                   // Add the offset from the moment refresh started for continuity
                   double startRotation = (_threshold / rotationStride) * 2 * math.pi;
                   rotation = startRotation + baseRotation + extraRotation;
                }

                return Center(
                  child: Transform.translate(
                    offset: Offset(0, yPos - 20),
                    child: Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: scale.clamp(0.0, 1.0),
                        child: Transform.rotate(
                          angle: rotation,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: Stack(
                                  children: [
                                    Positioned(top: 0, left: 0, child: _buildDot(Colors.black)),
                                    Positioned(top: 0, right: 0, child: _buildDot(Colors.black)),
                                    Positioned(bottom: 0, left: 0, child: _buildDot(Colors.black)),
                                    Positioned(bottom: 0, right: 0, child: _buildDot(Colors.black)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildDot(Color color) {
    return Container(
      width: 4.5,
      height: 4.5,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
