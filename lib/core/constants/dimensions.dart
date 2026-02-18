/// Spacing, sizing, and radius constants matching Pinterest's design system.
/// Animation curve: easeOutCubic ONLY.
class PinDimensions {
  PinDimensions._();

  // Grid — spec: 12–16dp
  static const double gridSpacing = 12.0;
  static const double gridSpacingLarge = 16.0;
  static const double masonryGap = 10.0;
  static const double masonryGapMobile = 10.0;

  // Card — spec: 16dp radius
  static const double cardRadius = 24.0;
  static const double cardRadiusSmall = 16.0;
  static const double cardRadiusLarge = 32.0;
  static const double cardElevation = 0.0;

  // Padding
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 12.0;
  static const double paddingL = 16.0;
  static const double paddingXL = 20.0;
  static const double paddingXXL = 24.0;

  // Nav
  static const double bottomNavHeight = 64.0;
  static const double bottomNavIconSize = 26.0;
  static const double appBarHeight = 56.0;

  // Button
  static const double buttonHeight = 40.0;
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightLarge = 48.0;
  static const double buttonRadius = 24.0;
  static const double saveButtonRadius = 20.0;
  static const double saveButtonPadding = 12.0;

  // Pin Card
  static const double pinTitleMaxLines = 2;
  static const double pinMetaHeight = 48.0;
  static const double pinOverlayPadding = 8.0;
  static const double pinSaveButtonSize = 32.0;

  // Avatar
  static const double avatarSmall = 24.0;
  static const double avatarMedium = 32.0;
  static const double avatarLarge = 48.0;
  static const double avatarXL = 80.0;

  // Board Card
  static const double boardCoverHeight = 160.0;
  static const double boardCoverRadius = 16.0;

  // Search
  static const double searchBarHeight = 48.0;
  static const double searchBarRadius = 24.0;
  static const double chipHeight = 40.0;
  static const double chipRadius = 20.0;

  // Detail
  static const double detailMaxWidth = 508.0;
  static const double detailImageMaxWidth = 600.0;
  static const double detailDesktopMaxWidth = 1016.0;

  // Animation — spec: Micro 120ms, Standard 220ms, easeOutCubic only
  static const int animDurationMicro = 120;
  static const int animDurationFast = 120;
  static const int animDurationNormal = 220;
  static const int animDurationSlow = 400;
  static const int animDurationHero = 350;

  // Breakpoints — spec: Mobile <600, Tablet 600–1024, Desktop >1024
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 1024.0;
}
