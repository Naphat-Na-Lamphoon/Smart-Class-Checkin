import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';
import 'services/local_storage_service.dart';
import 'services/location_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartClassApp());
}

class SmartClassApp extends StatelessWidget {
  const SmartClassApp({super.key});

  ThemeData _buildTheme() {
    const seed = Color(0xFF006D77);
    const surface = Color(0xFFF4F7FB);
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
      useMaterial3: true,
    );

    return base.copyWith(
      scaffoldBackgroundColor: surface,
      textTheme: GoogleFonts.promptTextTheme(base.textTheme).copyWith(
        headlineMedium: GoogleFonts.prompt(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        titleLarge: GoogleFonts.prompt(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF0B1220),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD0D8E4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD0D8E4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF006D77), width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storageService = LocalStorageService();
    final locationService = LocationService();

    return MaterialApp(
      title: 'Smart Class Check-in',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: HomeScreen(
        storageService: storageService,
        locationService: locationService,
      ),
    );
  }
}
