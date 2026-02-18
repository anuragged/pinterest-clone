import 'package:flutter/widgets.dart';
import '../constants/dimensions.dart';

enum DeviceType { mobile, tablet, desktop }

/// Responsive breakpoint utility for adaptive layouts.
class Responsive {
  Responsive._();

  static DeviceType deviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < PinDimensions.breakpointMobile) return DeviceType.mobile;
    if (width < PinDimensions.breakpointTablet) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static bool isMobile(BuildContext context) =>
      deviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      deviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      deviceType(context) == DeviceType.desktop;

  /// Masonry grid columns: mobile=2, tablet=3, desktop=4-5
  static int gridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < PinDimensions.breakpointMobile) return 2;
    if (width < PinDimensions.breakpointTablet) return 3;
    if (width < 1600) return 4;
    return 5;
  }

  /// Grid cross-axis spacing
  static double gridSpacing(BuildContext context) {
    return isMobile(context)
        ? PinDimensions.masonryGapMobile
        : PinDimensions.masonryGap;
  }

  /// Whether pin detail opens as modal overlay (desktop/tablet) or full page (mobile)
  static bool shouldShowPinAsModal(BuildContext context) =>
      !isMobile(context);
}
