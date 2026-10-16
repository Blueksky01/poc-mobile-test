import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/admin_model.dart';

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthService {
  /// Default backend URL loaded from environment variables
  static String get defaultBaseUrl => AppConfig.baseUrl;

  final String baseUrl;
  final http.Client _client;

  AuthService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? defaultBaseUrl,
        _client = client ?? http.Client();

  /// Admin login API call (POST /auth/login)
  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty) {
      throw AuthException('กรุณากรอก username');
    }
    if (password.isEmpty) {
      throw AuthException('กรุณากรอก password');
    }

    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'username': trimmedUsername,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is Map<String, dynamic>) {
          return LoginResponse.fromJson(decoded);
        }
        throw AuthException('รูปแบบข้อมูลตอบกลับไม่ถูกต้อง');
      }

      // Backend returns { statusCode, message, error }
      String errorMessage = 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ';
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String) {
          errorMessage = message;
        } else if (message is List && message.isNotEmpty) {
          errorMessage = message.join(', ');
        }
      }

      throw AuthException(errorMessage, statusCode: response.statusCode);
    } on AuthException {
      rethrow;
    } on FormatException {
      throw AuthException('ไม่สามารถแปลงข้อมูลตอบกลับจากเซิร์ฟเวอร์ได้');
    } catch (e) {
      // Check for network errors
      final errString = e.toString().toLowerCase();
      if (errString.contains('socketexception') ||
          errString.contains('connection refused') ||
          errString.contains('failed host lookup') ||
          errString.contains('clientexception')) {
        throw AuthException(
          'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ ($baseUrl) กรุณาตรวจสอบว่า Backend ทำงานอยู่',
        );
      }
      if (errString.contains('timeoutexception')) {
        throw AuthException('การเชื่อมต่อกับเซิร์ฟเวอร์หมดเวลา (Timeout)');
      }
      throw AuthException('เกิดข้อผิดพลาดในการเชื่อมต่อ: $e');
    }
  }
}
