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
          'id': '', // Invalid ID to test validation
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

      expect(controller.totalCount, 2); // 3rd item was invalid and filtered out
      expect(controller.employees.length, 2);
      expect(controller.isLoading, false);
      expect(controller.errorMessage, null);
    });

    test('Controller should filter by search keyword', () async {
      final mockService = MockEmployeeService(sampleList);
      final controller = EmployeeController(employeeService: mockService);
      await controller.fetchEmployees();

      // Search by name
      controller.setSearchQuery('วิภาดา');
      expect(controller.filteredCount, 1);
      expect(controller.employees.first.name, 'วิภาดา แสงสว่าง');

      // Search by ID
      controller.setSearchQuery('EMP-001');
      expect(controller.filteredCount, 1);
      expect(controller.employees.first.id, 'EMP-001');

      // Clear search
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

      // Overall numbers
      expect(controller.totalCount, 25);
      expect(controller.filteredCount, 25);
      expect(controller.totalPages, 3);
      expect(controller.pageSize, 10);

      // Page 1
      expect(controller.currentPage, 1);
      expect(controller.hasPreviousPage, false);
      expect(controller.hasNextPage, true);
      expect(controller.startIndex, 1);
      expect(controller.endIndex, 10);
      expect(controller.employees.length, 10);
      expect(controller.employees.first.name, 'พนักงานคนที่ 1');
      expect(controller.employees.last.name, 'พนักงานคนที่ 10');

      // Go to Page 2
      controller.nextPage();
      expect(controller.currentPage, 2);
      expect(controller.hasPreviousPage, true);
      expect(controller.hasNextPage, true);
      expect(controller.startIndex, 11);
      expect(controller.endIndex, 20);
      expect(controller.employees.length, 10);
      expect(controller.employees.first.name, 'พนักงานคนที่ 11');
      expect(controller.employees.last.name, 'พนักงานคนที่ 20');

      // Go to Page 3 (Last page with remaining 5 items)
      controller.nextPage();
      expect(controller.currentPage, 3);
      expect(controller.hasPreviousPage, true);
      expect(controller.hasNextPage, false);
      expect(controller.startIndex, 21);
      expect(controller.endIndex, 25);
      expect(controller.employees.length, 5);
      expect(controller.employees.first.name, 'พนักงานคนที่ 21');
      expect(controller.employees.last.name, 'พนักงานคนที่ 25');

      // Calling nextPage on last page should not exceed totalPages
      controller.nextPage();
      expect(controller.currentPage, 3);

      // Previous page
      controller.previousPage();
      expect(controller.currentPage, 2);

      // Direct setPage
      controller.setPage(1);
      expect(controller.currentPage, 1);

      // Clamping checks
      controller.setPage(999);
      expect(controller.currentPage, 3);
      controller.setPage(-5);
      expect(controller.currentPage, 1);

      // When searching/filtering, page should reset to 1
      controller.setPage(3);
      expect(controller.currentPage, 3);
      controller.setSearchQuery('พนักงานคนที่ 1');
      expect(controller.currentPage, 1);
    });
  });
}

