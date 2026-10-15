import 'package:flutter/material.dart';
import 'package:mypoc1/views/login_view.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = ThemeData.light().textTheme;

    return MaterialApp(
      theme: ThemeData(
        // Font หลัก: Sarabun
        fontFamily: GoogleFonts.sarabun().fontFamily,

        textTheme: baseTextTheme.copyWith(
          // Title และหัวข้อ ใช้ Google Sans Flex
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

          // รายละเอียดและข้อความทั่วไป ใช้ Sarabun
          bodyLarge: GoogleFonts.sarabun(fontSize: 16),
          bodyMedium: GoogleFonts.sarabun(fontSize: 14),
          bodySmall: GoogleFonts.sarabun(fontSize: 12),
        ),
      ),

      home: HomeScreen(),
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
                Navigator.push(
                  context, // ตอนนี้ context อยู่ใต้ MaterialApp แล้ว จะทำงานได้ถูกต้อง
                  MaterialPageRoute(builder: (context) => const LoginView()),
                );
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
