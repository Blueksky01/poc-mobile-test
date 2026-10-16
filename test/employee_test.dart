import 'package:flutter_test/flutter_test.dart';
import 'package:mypoc1/controllers/employee_controller.dart';
import 'package:mypoc1/models/address_model.dart';
import 'package:mypoc1/models/employee_model.dart';
import 'package:mypoc1/models/employee_status.dart';
import 'package:mypoc1/services/employee_service.dart';

class MockEmployeeService extends EmployeeService {
  final List<EmployeeModel> mockData;
  MockEmployeeService(this.mockData);

  @override
  Future<List<EmployeeModel>> fetchEmployees({String? search, String? department, String? status}) async {
    return mockData;
  }
}

void main() {
  group('Employee Data Model & Mapping Tests', () {
    test('Should parse AddressModel with nested fields correctly', () {
      final json = {
        'street': '36/22 ถนนสุขุมวิท',
        'subdistrict': 'คลองเตย',
        'district': 'คลองเตย',
        'province': 'กรุงเทพมหานคร',
        'postalCode': '10110',
      };

      final address = AddressModel.fromJson(json);
      expect(address.street, '36/22 ถนนสุขุมวิท');
      expect(address.subdistrict, 'คลองเตย');
      expect(address.district, 'คลองเตย');
      expect(address.province, 'กรุงเทพมหานคร');
      expect(address.postalCode, '10110');
      expect(address.formattedAddress, contains('คลองเตย'));
    });

    test('Should parse EmployeeModel and handle Thai nameInitial correctly', () {
      final json = {
        'id': 'EMP-31433',
        'name': 'สมชาย ศรีเจริญ',
        'email': 'somchai.sri18@example.com',
        'department': 'Engineering',
        'status': 'Active',
        'address': {
          'street': '36/22 ถนนสุขุมวิท',
          'subdistrict': 'คลองเตย',
          'district': 'คลองเตย',
          'province': 'กรุงเทพมหานคร',
          'postalCode': '10110',
        },
      };

      final employee = EmployeeModel.fromJson(json);
      expect(employee.id, 'EMP-31433');
      expect(employee.name, 'สมชาย ศรีเจริญ');
      expect(employee.nameInitial, 'ส');
      expect(employee.status, EmployeeStatus.active);
      expect(employee.address.province, 'กรุงเทพมหานคร');
    });

    test('Should map Status correctly including On Leave', () {
      expect(EmployeeStatus.fromString('Active'), EmployeeStatus.active);
      expect(EmployeeStatus.fromString('Inactive'), EmployeeStatus.inactive);
      expect(EmployeeStatus.fromString('On Leave'), EmployeeStatus.onLeave);
      expect(EmployeeStatus.fromString(null), EmployeeStatus.unknown);
    });
  });

  group('EmployeeController State & Validation Tests', () {
    late List<EmployeeModel> sampleList;

    setUp(() {
      sampleList = [
        EmployeeModel.fromJson({
          'id': 'EMP-001',
          'name': 'สมชาย ศรีเจริญ',
          'email': 'somchai@example.com',
          'department': 'Engineering',
          'status': 'Active',
          'address': {'street': '1/1', 'subdistrict': 'A', 'district': 'B', 'province': 'กทม', 'postalCode': '10110'},
        }),
        EmployeeModel.fromJson({
          'id': 'EMP-002',
          'name': 'วิภาดา แสงสว่าง',
          'email': 'wiphada@example.com',
          'department': 'Finance',
          'status': 'Inactive',
          'address': {'street': '2/2', 'subdistrict': 'C', 'district': 'D', 'province': 'เชียงใหม่', 'postalCode': '50000'},
        }),
        EmployeeModel.fromJson({
          'id': '', // รหัสพนักงานไม่ถูกต้องสำหรับทดสอบ Validation
          'name': '',
          'email': 'invalid',
          'department': 'HR',
          'status': 'On Leave',
          'address': null,
        }),
      ];
    });

    test('Controller should validate and discard corrupted employees', () async {
      final mockService = MockEmployeeService(sampleList);
      final controller = EmployeeController(employeeService: mockService);

      await controller.fetchEmployees();

      expect(controller.totalCount, 2); // รายการที่ 3 มีข้อมูลไม่ถูกต้องจึงถูกกรองออก
      expect(controller.employees.length, 2);
      expect(controller.isLoading, false);
      expect(controller.errorMessage, null);
    });

    test('Controller should filter by search keyword', () async {
      final mockService = MockEmployeeService(sampleList);
      final controller = EmployeeController(employeeService: mockService);
      await controller.fetchEmployees();

      // ค้นหาด้วยชื่อ
      controller.setSearchQuery('วิภาดา');
      expect(controller.filteredCount, 1);
      expect(controller.employees.first.name, 'วิภาดา แสงสว่าง');

      // ค้นหาด้วยรหัสพนักงาน
      controller.setSearchQuery('EMP-001');
      expect(controller.filteredCount, 1);
      expect(controller.employees.first.id, 'EMP-001');

      // ล้างการค้นหา
      controller.setSearchQuery('');
      expect(controller.filteredCount, 2);
    });

    test('Controller should filter by department', () async {
      final mockService = MockEmployeeService(sampleList);
      final controller = EmployeeController(employeeService: mockService);
      await controller.fetchEmployees();

      controller.setDepartment('Engineering');
      expect(controller.filteredCount, 1);
      expect(controller.employees.first.department, 'Engineering');

      controller.setDepartment('Finance');
      expect(controller.filteredCount, 1);
      expect(controller.employees.first.department, 'Finance');

      controller.setDepartment('All');
      expect(controller.filteredCount, 2);
    });

    test('Controller should paginate items with 10 items per page', () async {
      final manyEmployees = List.generate(
        25,
        (i) => EmployeeModel.fromJson({
          'id': 'EMP-${1000 + i}',
          'name': 'พนักงานคนที่ ${i + 1}',
          'email': 'emp$i@example.com',
          'department': i % 2 == 0 ? 'Engineering' : 'Finance',
          'status': 'Active',
          'address': {'street': '1/1', 'subdistrict': 'A', 'district': 'B', 'province': 'กทม', 'postalCode': '10110'},
        }),
      );

      final mockService = MockEmployeeService(manyEmployees);
      final controller = EmployeeController(employeeService: mockService);
      await controller.fetchEmployees();

      // ตรวจสอบตัวเลขโดยรวม
      expect(controller.totalCount, 25);
      expect(controller.filteredCount, 25);
      expect(controller.totalPages, 3);
      expect(controller.pageSize, 10);

      // หน้าที่ 1
      expect(controller.currentPage, 1);
      expect(controller.hasPreviousPage, false);
      expect(controller.hasNextPage, true);
      expect(controller.startIndex, 1);
      expect(controller.endIndex, 10);
      expect(controller.employees.length, 10);
      expect(controller.employees.first.name, 'พนักงานคนที่ 1');
      expect(controller.employees.last.name, 'พนักงานคนที่ 10');

      // ไปยังหน้าที่ 2
      controller.nextPage();
      expect(controller.currentPage, 2);
      expect(controller.hasPreviousPage, true);
      expect(controller.hasNextPage, true);
      expect(controller.startIndex, 11);
      expect(controller.endIndex, 20);
      expect(controller.employees.length, 10);
      expect(controller.employees.first.name, 'พนักงานคนที่ 11');
      expect(controller.employees.last.name, 'พนักงานคนที่ 20');

      // ไปยังหน้าที่ 3 (หน้าสุดท้ายมี 5 รายการที่เหลือ)
      controller.nextPage();
      expect(controller.currentPage, 3);
      expect(controller.hasPreviousPage, true);
      expect(controller.hasNextPage, false);
      expect(controller.startIndex, 21);
      expect(controller.endIndex, 25);
      expect(controller.employees.length, 5);
      expect(controller.employees.first.name, 'พนักงานคนที่ 21');
      expect(controller.employees.last.name, 'พนักงานคนที่ 25');

      // การเรียก nextPage ที่หน้าสุดท้ายต้องไม่เกินจำนวนหน้าทั้งหมด
      controller.nextPage();
      expect(controller.currentPage, 3);

      // ย้อนกลับไปหน้าก่อนหน้า
      controller.previousPage();
      expect(controller.currentPage, 2);

      // กำหนดหมายเลขหน้าโดยตรงด้วย setPage
      controller.setPage(1);
      expect(controller.currentPage, 1);

      // ตรวจสอบการจำกัดขอบเขตหมายเลขหน้า (Clamping)
      controller.setPage(999);
      expect(controller.currentPage, 3);
      controller.setPage(-5);
      expect(controller.currentPage, 1);

      // เมื่อค้นหาหรือกรองข้อมูล หมายเลขหน้าควรถูกรีเซ็ตกลับเป็น 1
      controller.setPage(3);
      expect(controller.currentPage, 3);
      controller.setSearchQuery('พนักงานคนที่ 1');
      expect(controller.currentPage, 1);
    });
  });
}

