import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/employee_model.dart';

class EmployeeServiceException implements Exception {
  final String message;
  final int? statusCode;

  EmployeeServiceException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class EmployeeService {
  /// Base URL matching host platform
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  final String baseUrl;
  final http.Client _client;

  EmployeeService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? defaultBaseUrl,
        _client = client ?? http.Client();

  /// Fetch all employees from backend API (/employees)
  Future<List<EmployeeModel>> fetchEmployees({String? search, String? department, String? status}) async {
    final queryParameters = <String, String>{};
    if (search != null && search.isNotEmpty) queryParameters['search'] = search;
    if (department != null && department.isNotEmpty && department != 'All') {
      queryParameters['department'] = department;
    }
    if (status != null && status.isNotEmpty && status != 'All') {
      queryParameters['status'] = status;
    }

    final uri = Uri.parse('$baseUrl/employees').replace(
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));

        // Handle both raw Array [ ... ] or Paginated Wrapper { data: [ ... ] }
        final List<dynamic> list;
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          list = decoded['data'] as List<dynamic>;
        } else {
          throw EmployeeServiceException('รูปแบบข้อมูลไม่ถูกต้องจาก Server');
        }

        return list
            .map((item) => EmployeeModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw EmployeeServiceException(
          'เกิดข้อผิดพลาดจาก Server (รหัส: ${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException {
      throw EmployeeServiceException(
        'ไม่สามารถเชื่อมต่อ Server ได้ กรุณาตรวจสอบว่า Backend เปิดอยู่ ($baseUrl)',
      );
    } catch (e) {
      if (e is EmployeeServiceException) rethrow;
      throw EmployeeServiceException('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e');
    }
  }
}
