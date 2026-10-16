import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String defaultLocalUrl = 'http://localhost:3000';
  static const String defaultAndroidUrl = 'http://10.0.2.2:3000';

  /// โหลดการตั้งค่าสภาพแวดล้อม (Environment configuration)
  static Future<void> initialize({String fileName = '.env'}) async {
    try {
      await dotenv.load(fileName: fileName, isOptional: true);
    } catch (e) {
      debugPrint('Warning: Could not load $fileName: $e');
    }
  }

  /// ดึง Base URL แบบไดนามิกตามสภาพแวดล้อมและแพลตฟอร์มที่ใช้งาน
  static String get baseUrl {
    if (dotenv.isInitialized) {
      if (kIsWeb) {
        return dotenv.maybeGet('PUBLIC_URL') ??
            dotenv.maybeGet('API_URL') ??
            dotenv.maybeGet('BASE_URL') ??
            defaultLocalUrl;
      }
      if (Platform.isAndroid) {
        return dotenv.maybeGet('MOBILE_URL') ??
            dotenv.maybeGet('API_URL') ??
            dotenv.maybeGet('BASE_URL') ??
            defaultAndroidUrl;
      }
      return dotenv.maybeGet('PUBLIC_URL') ??
          dotenv.maybeGet('API_URL') ??
          dotenv.maybeGet('BASE_URL') ??
          defaultLocalUrl;
    }

    // ค่าเริ่มต้นสำรองกรณีที่ dotenv ยังไม่ได้ถูกโหลด
    if (kIsWeb) return defaultLocalUrl;
    if (Platform.isAndroid) return defaultAndroidUrl;
    return defaultLocalUrl;
  }

  static String? get publicUrl =>
      dotenv.isInitialized ? dotenv.maybeGet('PUBLIC_URL') : null;

  static String? get mobileUrl =>
      dotenv.isInitialized ? dotenv.maybeGet('MOBILE_URL') : null;

  static String? get port =>
      dotenv.isInitialized ? dotenv.maybeGet('PORT') : null;

  static String? get defaultAdminUsername =>
      dotenv.isInitialized ? dotenv.maybeGet('DEFAULT_ADMIN_USERNAME') : null;

  static String? get defaultAdminPassword =>
      dotenv.isInitialized ? dotenv.maybeGet('DEFAULT_ADMIN_PASSWORD') : null;

  static String? get defaultAdminName =>
      dotenv.isInitialized ? dotenv.maybeGet('DEFAULT_ADMIN_NAME') : null;

  static String? get(String key, {String? fallback}) {
    if (!dotenv.isInitialized) return fallback;
    return dotenv.maybeGet(key, fallback: fallback);
  }
}
