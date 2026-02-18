import 'package:flutter/services.dart';

/// Centralized haptic feedback matching Pinterest's tactile spec.
/// Light: tap pin, Selection: nav switch
/// Medium: save pin
/// Heavy: create board
class Haptics {
  Haptics._();

  /// Light tap — pin card tap, chip tap
  static Future<void> light() => HapticFeedback.lightImpact();

  /// Medium impact — save pin, follow user
  static Future<void> medium() => HapticFeedback.mediumImpact();

  /// Heavy impact — create board, delete action
  static Future<void> heavy() => HapticFeedback.heavyImpact();

  /// Selection click — bottom nav switch
  static Future<void> selection() => HapticFeedback.selectionClick();
}
