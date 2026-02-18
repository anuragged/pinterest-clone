import 'dart:ui';

/// Pinterest-exact color palette.
/// Every hex value matched from the production Pinterest app.
class PinColors {
  PinColors._();

  // Brand
  static const Color pinterestRed = Color(0xFFE60023);
  static const Color pinterestRedDark = Color(0xFFAD081B);
  static const Color pinterestRedHover = Color(0xFFCC0000);

  // Backgrounds
  static const Color white = Color(0xFFFFFFFF);
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF0F0F0);
  static const Color backgroundWash = Color(0xFFE9E9E9);

  // Text — spec-exact
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF5F5F5F);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textLink = Color(0xFF0076D3);

  // Borders & Dividers — spec: Divider #EFEFEF
  static const Color borderDefault = Color(0xFFCDCDCD);
  static const Color borderLight = Color(0xFFEFEFEF);
  static const Color divider = Color(0xFFEFEFEF);

  // Overlays — spec: Overlay Black rgba(0,0,0,0.25)
  static const Color overlayBlack = Color(0x40000000); // rgba(0,0,0,0.25)
  static const Color overlayDark = Color(0x80000000);
  static const Color overlayMedium = Color(0x59000000);
  static const Color overlayLight = Color(0x33000000);
  static const Color overlayPinHover = Color(0x40000000); // rgba(0,0,0,0.25)

  // Shimmer
  static const Color shimmerBase = Color(0xFFE8E8E8);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Status
  static const Color success = Color(0xFF008753);
  static const Color error = Color(0xFFCC0000);
  static const Color warning = Color(0xFFEFAD1A);

  // Icons
  static const Color iconDefault = Color(0xFF111111);
  static const Color iconSecondary = Color(0xFF5F5F5F);

  // Chips
  static const Color chipBackground = Color(0xFF111111);
  static const Color chipText = Color(0xFFFFFFFF);

  // Category chip colors (Pinterest search categories)
  static const List<Color> categoryColors = [
    Color(0xFFB28B67),
    Color(0xFF618B4A),
    Color(0xFF1B7B8E),
    Color(0xFF3F51B5),
    Color(0xFF8E24AA),
    Color(0xFFC62828),
    Color(0xFFEF6C00),
    Color(0xFF00838F),
    Color(0xFF4E342E),
    Color(0xFF546E7A),
  ];
}
