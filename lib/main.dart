import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'controllers/auth_controller.dart';
import 'controllers/employee_controller.dart';
import 'services/auth_service.dart';
import 'services/employee_service.dart';
import 'views/login_view.dart';
import 'views/render_list_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize();

  runApp(
    // [DI = Provider] ฉีด Service และ Controller ให้ทั้งแอปผ่าน MultiProvider
    MultiProvider(
      providers: [
        // Auth Dependencies
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(
            authService: context.read<AuthService>(),
          ),
        ),

        // Employee Dependencies (MVC)
        Provider<EmployeeService>(
          create: (_) => EmployeeService(),
        ),
        ChangeNotifierProvider<EmployeeController>(
          create: (context) => EmployeeController(
            employeeService: context.read<EmployeeService>(),
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
      initialRoute: '/login',
      routes: {
        '/': (context) => const LoginView(),
        '/login': (context) => const LoginView(),
        '/render-list': (context) => const RenderListView(),
      },
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
        ),
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
