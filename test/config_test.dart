import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mypoc1/config/app_config.dart';
import 'package:mypoc1/services/auth_service.dart';
import 'package:mypoc1/services/employee_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppConfig Tests', () {
    tearDown(() {
      dotenv.clean();
    });

    test('Falls back to defaults when dotenv is not initialized', () {
      dotenv.clean();
      expect(AppConfig.publicUrl, isNull);
      expect(AppConfig.mobileUrl, isNull);
      expect(AppConfig.port, isNull);
      expect(AppConfig.baseUrl, isNotEmpty);
      expect(AuthService.defaultBaseUrl, equals(AppConfig.baseUrl));
      expect(EmployeeService.defaultBaseUrl, equals(AppConfig.baseUrl));
    });

    test('Reads environment variables when initialized', () {
      dotenv.loadFromString(
        envString: '''
PORT=3000
PUBLIC_URL=http://localhost:3000
MOBILE_URL=http://10.0.2.2:3000
DEFAULT_ADMIN_USERNAME=admin
DEFAULT_ADMIN_PASSWORD=admin1234
DEFAULT_ADMIN_NAME=ผู้ดูแลระบบ (Admin)
''',
      );

      expect(AppConfig.port, equals('3000'));
      expect(AppConfig.publicUrl, equals('http://localhost:3000'));
      expect(AppConfig.mobileUrl, equals('http://10.0.2.2:3000'));
      expect(AppConfig.defaultAdminUsername, equals('admin'));
      expect(AppConfig.defaultAdminPassword, equals('admin1234'));
      expect(AppConfig.defaultAdminName, equals('ผู้ดูแลระบบ (Admin)'));
      expect(AppConfig.get('PORT'), equals('3000'));
      expect(AppConfig.get('NON_EXISTENT', fallback: 'default_val'), equals('default_val'));
    });

    test('Custom baseUrl takes effect in AuthService and EmployeeService', () {
      dotenv.loadFromString(
        envString: '''
PUBLIC_URL=https://my-custom-api.example.com
MOBILE_URL=https://my-custom-mobile-api.example.com
''',
      );

      final authService = AuthService();
      final employeeService = EmployeeService();

      expect(authService.baseUrl, equals(AppConfig.baseUrl));
      expect(employeeService.baseUrl, equals(AppConfig.baseUrl));
      expect(authService.baseUrl.contains('my-custom'), isTrue);
    });
  });
}
