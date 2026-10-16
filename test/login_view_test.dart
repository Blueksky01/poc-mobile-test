import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:mypoc1/controllers/auth_controller.dart';
import 'package:mypoc1/services/auth_service.dart';
import 'package:mypoc1/views/login_view.dart';
import 'package:mypoc1/views/render_list_view.dart';

Widget createTestApp({AuthController? authController}) {
  final controller = authController ?? AuthController();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthController>.value(value: controller),
    ],
    child: MaterialApp(
      initialRoute: '/login',
      routes: {
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

    // Initial obscure password is true -> visibility_off icon
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);

    // Tap toggle icon to switch visibility
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('Submitting empty username shows validation snackbar', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text('กรุณากรอก username'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Successful login navigates to RenderListView using Navigator', (WidgetTester tester) async {
    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode({
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
    expect(find.text('ชื่อ: ผู้ดูแลระบบ (Admin)'), findsOneWidget);
  });
}
