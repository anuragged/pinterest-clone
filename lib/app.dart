import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/colors.dart';
import 'core/router/app_router.dart';
import 'presentation/providers/theme_provider.dart';

/// Root application widget.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Pinterest',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: PinColors.pinterestRed,
        scaffoldBackgroundColor: PinColors.backgroundPrimary,
        appBarTheme: const AppBarTheme(
          backgroundColor: PinColors.backgroundPrimary,
          foregroundColor: PinColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
        splashFactory: InkSparkle.splashFactory,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: PinColors.textPrimary),
          bodyMedium: TextStyle(color: PinColors.textPrimary),
          bodySmall: TextStyle(color: PinColors.textSecondary),
        ),
        dividerTheme: const DividerThemeData(
          color: PinColors.borderLight,
          thickness: 0.5,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: PinColors.pinterestRed,
        scaffoldBackgroundColor: const Color(0xFF111111),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111111),
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
        splashFactory: InkSparkle.splashFactory,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white70),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF2B2B2B),
          thickness: 0.5,
        ),
      ),
    );
  }
}
