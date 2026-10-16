import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mypoc1/controllers/auth_controller.dart';
import 'package:mypoc1/models/admin_model.dart';
import 'package:mypoc1/services/auth_service.dart';

void main() {
  group('Admin Model Test', () {
    test('AdminUser and LoginResponse parse from JSON correctly', () {
      final json = {
        'accessToken': 'dummy-access-token',
        'refreshToken': 'dummy-refresh-token',
        'admin': {
          'id': 1,
          'username': 'admin',
          'name': 'ผู้ดูแลระบบ (Admin)',
          'role': 'admin',
        },
      };

      final response = LoginResponse.fromJson(json);

      expect(response.accessToken, 'dummy-access-token');
      expect(response.refreshToken, 'dummy-refresh-token');
      expect(response.admin.id, 1);
      expect(response.admin.username, 'admin');
      expect(response.admin.name, 'ผู้ดูแลระบบ (Admin)');
      expect(response.admin.role, 'admin');

      final serialized = response.toJson();
      expect(serialized['accessToken'], 'dummy-access-token');
      expect(serialized['admin']['username'], 'admin');
    });
  });

  group('AuthService Test', () {
    test('login success returns LoginResponse', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/auth/login');
        expect(request.method, 'POST');
        final body = jsonDecode(request.body);
        expect(body['username'], 'admin');
        expect(body['password'], 'admin1234');

        return http.Response(
          jsonEncode({
            'accessToken': 'jwt-token-123',
            'refreshToken': 'refresh-token-456',
            'admin': {
              'id': 1,
              'username': 'admin',
              'name': 'ผู้ดูแลระบบ (Admin)',
              'role': 'admin',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final authService = AuthService(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      final result = await authService.login(
        username: 'admin',
        password: 'admin1234',
      );

      expect(result.accessToken, 'jwt-token-123');
      expect(result.admin.username, 'admin');
    });

    test('login failure with 401 throws AuthException with backend message', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'message': 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง',
            'error': 'Unauthorized',
            'statusCode': 401,
          }),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      final authService = AuthService(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      expect(
        () => authService.login(username: 'wrong', password: 'wrong'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง',
          ),
        ),
      );
    });

    test('login validation throws when empty username or password', () async {
      final authService = AuthService(baseUrl: 'http://localhost:3000');

      expect(
        () => authService.login(username: '', password: '123'),
        throwsA(isA<AuthException>().having((e) => e.message, 'message', 'กรุณากรอก username')),
      );

      expect(
        () => authService.login(username: 'admin', password: ''),
        throwsA(isA<AuthException>().having((e) => e.message, 'message', 'กรุณากรอก password')),
      );
    });
  });

  group('AuthController Test', () {
    test('successful login updates state correctly', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'accessToken': 'jwt-test',
            'refreshToken': 'ref-test',
            'admin': {
              'id': 1,
              'username': 'admin',
              'name': 'ผู้ดูแลระบบ (Admin)',
              'role': 'admin',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final authService = AuthService(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );
      final controller = AuthController(authService: authService);

      expect(controller.isLoading, false);
      expect(controller.isAuthenticated, false);

      final success = await controller.login('admin', 'admin1234');

      expect(success, true);
      expect(controller.isLoading, false);
      expect(controller.isAuthenticated, true);
      expect(controller.currentAdmin?.username, 'admin');
      expect(controller.errorMessage, isNull);

      controller.logout();
      expect(controller.isAuthenticated, false);
      expect(controller.currentAdmin, isNull);
    });

    test('failed login sets errorMessage', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'message': 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง',
            'error': 'Unauthorized',
            'statusCode': 401,
          }),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      final authService = AuthService(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );
      final controller = AuthController(authService: authService);

      final success = await controller.login('admin', 'wrongpass');

      expect(success, false);
      expect(controller.isLoading, false);
      expect(controller.isAuthenticated, false);
      expect(controller.errorMessage, 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง');

      controller.clearError();
      expect(controller.errorMessage, isNull);
    });
  });
}
