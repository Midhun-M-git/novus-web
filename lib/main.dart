import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/home/home_page.dart';

void main() {
  runApp(const NovusTechApp());
}

class NovusTechApp extends StatelessWidget {
  const NovusTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NovusTech',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF0F172A), // Deep Slate
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6), // Tech Blue
          secondary: const Color(0xFF10B981), // Emerald
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: const Color(0xFF1E293B),
          displayColor: const Color(0xFF0F172A),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
      },
    );
  }
}
