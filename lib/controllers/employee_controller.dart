import 'package:flutter/foundation.dart';
import '../models/employee_model.dart';
import '../models/employee_status.dart';
import '../services/employee_service.dart';

class EmployeeController extends ChangeNotifier {
  final EmployeeService employeeService;

  EmployeeController({required this.employeeService});

  // สถานะภายใน (Internal states)
  List<EmployeeModel> _allEmployees = [];
  List<EmployeeModel> _filteredEmployees = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedDepartment = 'All';
  EmployeeStatus? _selectedStatus;

  // สถานะการแบ่งหน้า (10 รายการต่อหน้า)
  int _currentPage = 1;
  static const int _pageSize = 10;

  // Getter สำหรับภายนอกเรียกใช้งาน
  List<EmployeeModel> get employees => paginatedEmployees;
  List<EmployeeModel> get filteredEmployees => _filteredEmployees;
  List<EmployeeModel> get allEmployees => _allEmployees;
  int get totalCount => _allEmployees.length;
  int get filteredCount => _filteredEmployees.length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedDepartment => _selectedDepartment;
  EmployeeStatus? get selectedStatus => _selectedStatus;

  // Getter สำหรับระบบแบ่งหน้า (Pagination)
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalPages => _filteredEmployees.isEmpty ? 1 : (_filteredEmployees.length / _pageSize).ceil();
  bool get hasPreviousPage => _currentPage > 1;
  bool get hasNextPage => _currentPage < totalPages;

  int get startIndex => _filteredEmployees.isEmpty ? 0 : (_currentPage - 1) * _pageSize + 1;
  int get endIndex {
    if (_filteredEmployees.isEmpty) return 0;
    final end = _currentPage * _pageSize;
    return end > _filteredEmployees.length ? _filteredEmployees.length : end;
  }

  /// รายการพนักงานในหน้าปัจจุบันตามการแบ่งหน้า (10 รายการต่อหน้า)
  List<EmployeeModel> get paginatedEmployees {
    if (_filteredEmployees.isEmpty) return [];
    final start = (_currentPage - 1) * _pageSize;
    if (start >= _filteredEmployees.length) return [];
    final end = (start + _pageSize > _filteredEmployees.length)
        ? _filteredEmployees.length
        : start + _pageSize;
    return _filteredEmployees.sublist(start, end);
  }

  /// รายชื่อแผนกทั้งหมดแบบไดนามิกจากข้อมูลที่ดึงมา
  List<String> get availableDepartments {
    final depts = _allEmployees.map((e) => e.department).toSet().toList()
      ..sort();
    return ['All', ...depts];
  }

  /// [Validate] ตรวจสอบความถูกต้องของข้อมูล Employee Model
  bool validateEmployee(EmployeeModel employee) {
    if (employee.id.trim().isEmpty) return false;
    if (employee.name.trim().isEmpty || employee.name == 'ไม่ระบุชื่อ') return false;
    
    // ตรวจสอบรูปแบบอีเมลเบื้องต้น
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (employee.email != '-' && !emailRegex.hasMatch(employee.email.trim())) {
      return false;
    }

    return true;
  }

  /// ดึงข้อมูลพนักงานจาก Backend
  Future<void> fetchEmployees() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await employeeService.fetchEmployees();

      // [ตรวจสอบและกรองข้อมูลที่ไม่ถูกต้อง]
      // กรองเฉพาะพนักงานที่มีข้อมูลถูกต้องตามกฎ Business Rule
      _allEmployees = list.where(validateEmployee).toList();
      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString();
      _allEmployees = [];
      _filteredEmployees = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// อัปเดตคำค้นหาและประมวลผลตัวกรองใหม่
  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    _currentPage = 1;
    _applyFilters();
    notifyListeners();
  }

  /// อัปเดตตัวกรองแผนก
  void setDepartment(String department) {
    _selectedDepartment = department;
    _currentPage = 1;
    _applyFilters();
    notifyListeners();
  }

  /// อัปเดตตัวกรองสถานะ
  void setStatus(EmployeeStatus? status) {
    _selectedStatus = status;
    _currentPage = 1;
    _applyFilters();
    notifyListeners();
  }

  /// ล้างค่าการค้นหาและตัวกรองทั้งหมด
  void clearFilters() {
    _searchQuery = '';
    _selectedDepartment = 'All';
    _selectedStatus = null;
    _currentPage = 1;
    _applyFilters();
    notifyListeners();
  }

  /// กำหนดหมายเลขหน้าปัจจุบัน
  void setPage(int page) {
    final target = page.clamp(1, totalPages);
    if (_currentPage != target) {
      _currentPage = target;
      notifyListeners();
    }
  }

  /// ไปยังหน้าถัดไป
  void nextPage() {
    if (hasNextPage) {
      _currentPage++;
      notifyListeners();
    }
  }

  /// ไปยังหน้าก่อนหน้า
  void previousPage() {
    if (hasPreviousPage) {
      _currentPage--;
      notifyListeners();
    }
  }

  /// ดึงลงเพื่อรีเฟรชข้อมูล (Pull-to-refresh)
  Future<void> refresh() async {
    await fetchEmployees();
  }

  /// ประมวลผลการกรองข้อมูลภายใน
  void _applyFilters() {
    _filteredEmployees = _allEmployees.where((employee) {
      // 1. ตัวกรองแผนก
      if (_selectedDepartment != 'All' &&
          employee.department.toLowerCase() != _selectedDepartment.toLowerCase()) {
        return false;
      }

      // 2. ตัวกรองสถานะ
      if (_selectedStatus != null && employee.status != _selectedStatus) {
        return false;
      }

      // 3. ตัวกรองคำค้นหา
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchId = employee.id.toLowerCase().contains(query);
        final matchName = employee.name.toLowerCase().contains(query);
        final matchEmail = employee.email.toLowerCase().contains(query);
        final matchDept = employee.department.toLowerCase().contains(query);
        final matchProvince = employee.address.province.toLowerCase().contains(query);
        final matchDistrict = employee.address.district.toLowerCase().contains(query);

        if (!matchId &&
            !matchName &&
            !matchEmail &&
            !matchDept &&
            !matchProvince &&
            !matchDistrict) {
          return false;
        }
      }

      return true;
    }).toList();

    // ตรวจสอบให้แน่ใจว่าหมายเลขหน้าปัจจุบันอยู่ในช่วงที่ถูกต้อง
    if (_currentPage > totalPages) {
      _currentPage = totalPages > 0 ? totalPages : 1;
    }
  }
}
