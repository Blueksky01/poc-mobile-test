import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:mypoc1/controllers/auth_controller.dart';
import 'package:mypoc1/controllers/employee_controller.dart';
import 'package:mypoc1/services/auth_service.dart';
import 'package:mypoc1/services/employee_service.dart';
import 'package:mypoc1/models/employee_model.dart';
import 'package:mypoc1/views/login_view.dart';
import 'package:mypoc1/views/render_list_view.dart';

class MockEmployeeServiceForLoginTest extends EmployeeService {
  @override
  Future<List<EmployeeModel>> fetchEmployees({String? search, String? department, String? status}) async {
    return [];
  }
}

Widget createTestApp({
  AuthController? authController,
  String initialRoute = '/login',
}) {
  final controller = authController ?? AuthController();
  final employeeController = EmployeeController(
    employeeService: EmployeeService(client: MockClient((_) async => http.Response('[]', 200))),
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthController>.value(value: controller),
      ChangeNotifierProvider<EmployeeController>.value(value: employeeController),
    ],
    child: MaterialApp(
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const LoginView(),
        '/login': (context) => const LoginView(),
        '/render-list': (context) => const RenderListView(),
      },
    ),
  );
}

void main() {
  testWidgets('LoginView renders input fields and login button', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());

    expect(find.text('Login Render List'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'username'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });

  testWidgets('Shows snackbar if username is empty', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.widgetWithText(SnackBar, 'กรุณากรอก username'), findsOneWidget);
  });

  testWidgets('Shows snackbar if password is empty', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());

    await tester.enterText(find.widgetWithText(TextField, 'username'), 'admin');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.widgetWithText(SnackBar, 'กรุณากรอก password'), findsOneWidget);
  });

  testWidgets('Successful login navigates to RenderListView using Navigator', (WidgetTester tester) async {
    final mockClient = MockClient((request) async {
      return http.Response(
        json.encode({
          'accessToken': 'dummy-access',
          'refreshToken': 'dummy-refresh',
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

    final authController = AuthController(
      authService: AuthService(baseUrl: 'http://localhost:3000', client: mockClient),
    );

    await tester.pumpWidget(createTestApp(authController: authController));

    await tester.enterText(find.widgetWithText(TextField, 'username'), 'admin');
    await tester.enterText(find.widgetWithText(TextField, 'password'), 'admin1234');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.byType(RenderListView), findsOneWidget);
    expect(find.text('รายชื่อพนักงาน'), findsOneWidget);
  });

  testWidgets('Direct access to RenderListView redirects to LoginView when unauthenticated', (WidgetTester tester) async {
    final authController = AuthController(); // ยังไม่ได้เข้าสู่ระบบ

    await tester.pumpWidget(createTestApp(
      authController: authController,
      initialRoute: '/render-list',
    ));
    await tester.pumpAndSettle();

    // ตรวจสอบว่าถูกเปลี่ยนเส้นทางกลับไปยัง LoginView
    expect(find.byType(LoginView), findsOneWidget);
    expect(find.text('Login Render List'), findsOneWidget);
  });

  testWidgets('Logout from RenderListView redirects back to LoginView', (WidgetTester tester) async {
    final mockClient = MockClient((request) async {
      return http.Response(
        json.encode({
          'accessToken': 'dummy-access',
          'refreshToken': 'dummy-refresh',
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

    final authController = AuthController(
      authService: AuthService(baseUrl: 'http://localhost:3000', client: mockClient),
    );

    // เข้าสู่ระบบก่อน
    await authController.login('admin', 'admin1234');

    await tester.pumpWidget(createTestApp(
      authController: authController,
      initialRoute: '/render-list',
    ));
    await tester.pumpAndSettle();

    expect(find.byType(RenderListView), findsOneWidget);

    // กดไอคอนออกจากระบบ
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    // ตรวจสอบว่าออกจากระบบแล้วและเปลี่ยนเส้นทางกลับไปยัง LoginView
    expect(authController.isAuthenticated, false);
    expect(find.byType(LoginView), findsOneWidget);
  });
}
