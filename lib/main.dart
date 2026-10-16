import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'services/auth_service.dart';
import 'views/login_view.dart';
import 'views/render_list_view.dart';

void main() {
  runApp(
    // [DI = Provider] ฉีด Service และ Controller ให้ทั้งแอปผ่าน MultiProvider
    MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(
            authService: context.read<AuthService>(),
          ),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = ThemeData.light().textTheme;

    return MaterialApp(
      title: 'POC App',
      // [Navigation / Routing = Navigator] กำหนด Named Routes
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginView(),
        '/render-list': (context) => const RenderListView(),
      },
      theme: ThemeData(
        fontFamily: GoogleFonts.sarabun().fontFamily,
        textTheme: baseTextTheme.copyWith(
          headlineLarge: GoogleFonts.googleSansFlex(
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
          headlineMedium: GoogleFonts.googleSansFlex(
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: GoogleFonts.googleSansFlex(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: GoogleFonts.sarabun(fontSize: 16),
          bodyMedium: GoogleFonts.sarabun(fontSize: 14),
          bodySmall: GoogleFonts.sarabun(fontSize: 12),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('My POC App'))),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Hello World!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // [Navigation / Routing = Navigator]
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
