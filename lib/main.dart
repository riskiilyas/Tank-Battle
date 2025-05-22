import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tank_battle/screens/main_menu_screen.dart';

import 'settings/game_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force landscape orientation for better gameplay and menu experience
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.black,
    ),
  );

  // Initialize game settings
  final gameSettings = GameSettings();
  await gameSettings.init();

  runApp(const TankBattleApp());
}

class TankBattleApp extends StatelessWidget {
  const TankBattleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tank Battle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.orbitronTextTheme(
          Theme.of(context).textTheme,
        ),
        scaffoldBackgroundColor: Colors.black,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainMenuScreen(),
    );
  }
}