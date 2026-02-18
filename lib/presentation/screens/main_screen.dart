import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/create_sheet.dart';

/// Main screen with bottom navigation shell.
/// Uses StatefulShellRoute's navigation shell to preserve tab state.
class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PinColors.backgroundPrimary,
      body: navigationShell,
      bottomNavigationBar: PinterestBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          if (index == 2) {
            CreateSheet.show(context);
            return;
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
