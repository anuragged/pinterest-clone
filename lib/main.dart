import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait on mobile for Pinterest-authentic feel
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  runApp(
    ProviderScope(
      child: ClerkAuth(
        config: ClerkAuthConfig(
          publishableKey: 'pk_test_Y2xlcmsuYW51cmFnLnBpbnRlcmVzdC5jbG9uZS5kZXYk',
        ),
        child: const App(),
      ),
    ),
  );
}
