import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mypoc1/controllers/auth_controller.dart';
import 'package:mypoc1/controllers/employee_controller.dart';
import 'package:mypoc1/models/admin_model.dart';
import 'package:mypoc1/models/employee_model.dart';
import 'package:mypoc1/services/employee_service.dart';
import 'package:mypoc1/views/render_list_view.dart';
import 'package:mypoc1/components/pagination_bar.dart';

class MockEmployeeServiceForViewTest extends EmployeeService {
  final List<EmployeeModel> data;
  MockEmployeeServiceForViewTest(this.data);

  @override
  Future<List<EmployeeModel>> fetchEmployees({String? search, String? department, String? status}) async {
    return data;
  }
}

class FakeAuthController extends AuthController {
  @override
  bool get isAuthenticated => true;

  @override
  AdminUser? get currentAdmin => AdminUser(id: 1, username: 'admin', name: 'Admin', role: 'admin');
}

void main() {
  testWidgets('RenderListView shows exactly 10 items per page and switches page correctly', (WidgetTester tester) async {
    final mockEmployees = List.generate(
      25,
      (i) => EmployeeModel.fromJson({
        'id': 'EMP-${1000 + i}',
        'name': 'พนักงานคนที่ ${i + 1}',
        'email': 'emp$i@example.com',
        'department': 'Engineering',
        'status': 'Active',
        'address': {'street': '1/1', 'subdistrict': 'A', 'district': 'B', 'province': 'กทม', 'postalCode': '10110'},
      }),
    );

    final authController = FakeAuthController();
    final employeeController = EmployeeController(
      employeeService: MockEmployeeServiceForViewTest(mockEmployees),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthController>.value(value: authController),
          ChangeNotifierProvider<EmployeeController>.value(value: employeeController),
        ],
        child: const MaterialApp(
          home: RenderListView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // ตรวจสอบว่า controller มี 10 รายการสำหรับหน้าที่ 1
    expect(employeeController.employees.length, 10);
    expect(employeeController.currentPage, 1);
    expect(employeeController.employees.first.name, 'พนักงานคนที่ 1');
    expect(employeeController.employees.last.name, 'พนักงานคนที่ 10');

    // ตรวจสอบว่า PaginationBar แสดงผลแล้ว
    expect(find.byType(PaginationBar), findsOneWidget);
    expect(find.text('แสดง 1 - 10 จาก 25 รายการ (หน้า 1 จาก 3)'), findsOneWidget);

    // กดเลือกหน้าที่ 2
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();

    // ตรวจสอบว่าหน้าที่ 2 แสดงผล 10 รายการ (รายการที่ 11-20)
    expect(employeeController.currentPage, 2);
    expect(employeeController.employees.length, 10);
    expect(employeeController.employees.first.name, 'พนักงานคนที่ 11');
    expect(employeeController.employees.last.name, 'พนักงานคนที่ 20');
    expect(find.text('แสดง 11 - 20 จาก 25 รายการ (หน้า 2 จาก 3)'), findsOneWidget);

    // กดเลือกหน้าที่ 3 (หน้าสุดท้ายมี 5 รายการ)
    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();

    expect(employeeController.currentPage, 3);
    expect(employeeController.employees.length, 5);
    expect(employeeController.employees.first.name, 'พนักงานคนที่ 21');
    expect(employeeController.employees.last.name, 'พนักงานคนที่ 25');
    expect(find.text('แสดง 21 - 25 จาก 25 รายการ (หน้า 3 จาก 3)'), findsOneWidget);
  });
}
