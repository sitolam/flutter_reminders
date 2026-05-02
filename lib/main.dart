import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'services/notification_service.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const ReminderApp());
}

class ReminderApp extends StatelessWidget {
  const ReminderApp({super.key});

  // Fallback seed used when the device doesn't expose dynamic colors
  // (older Android, or non-supported OEMs).
  static const _fallbackSeed = Color(0xFF6750A4);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final ColorScheme lightScheme = lightDynamic?.harmonized() ??
            ColorScheme.fromSeed(seedColor: _fallbackSeed);
        final ColorScheme darkScheme = darkDynamic?.harmonized() ??
            ColorScheme.fromSeed(
              seedColor: _fallbackSeed,
              brightness: Brightness.dark,
            );

        return MaterialApp(
          title: 'Reminders',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          theme: ThemeData(
            colorScheme: lightScheme,
            useMaterial3: true,
            scaffoldBackgroundColor: lightScheme.surface,
          ),
          darkTheme: ThemeData(
            colorScheme: darkScheme,
            useMaterial3: true,
            scaffoldBackgroundColor: darkScheme.surface,
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
