import 'package:flutter/foundation.dart';
import '../models/employee_model.dart';
import '../models/employee_status.dart';
import '../services/employee_service.dart';

class EmployeeController extends ChangeNotifier {
  final EmployeeService employeeService;

  EmployeeController({required this.employeeService});

  // Internal states
  List<EmployeeModel> _allEmployees = [];
  List<EmployeeModel> _filteredEmployees = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedDepartment = 'All';
  EmployeeStatus? _selectedStatus;

  // Public getters
  List<EmployeeModel> get employees => _filteredEmployees;
  int get totalCount => _allEmployees.length;
  int get filteredCount => _filteredEmployees.length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedDepartment => _selectedDepartment;
  EmployeeStatus? get selectedStatus => _selectedStatus;

  /// Dynamic list of all available departments from the fetched data
  List<String> get availableDepartments {
    final depts = _allEmployees.map((e) => e.department).toSet().toList()
      ..sort();
    return ['All', ...depts];
  }

  /// [Validate] ตรวจสอบความถูกต้องของข้อมูล Employee Model
  bool validateEmployee(EmployeeModel employee) {
    if (employee.id.trim().isEmpty) return false;
    if (employee.name.trim().isEmpty || employee.name == 'ไม่ระบุชื่อ') return false;
    
    // Simple email format check
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (employee.email != '-' && !emailRegex.hasMatch(employee.email.trim())) {
      return false;
    }

    return true;
  }

  /// Fetch employees from backend
  Future<void> fetchEmployees() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await employeeService.fetchEmployees();

      // [Validate & Filter Corrupted Data]
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

  /// Update search query and re-filter
  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    _applyFilters();
    notifyListeners();
  }

  /// Update department filter
  void setDepartment(String department) {
    _selectedDepartment = department;
    _applyFilters();
    notifyListeners();
  }

  /// Update status filter
  void setStatus(EmployeeStatus? status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }

  /// Clear all search and filter conditions
  void clearFilters() {
    _searchQuery = '';
    _selectedDepartment = 'All';
    _selectedStatus = null;
    _applyFilters();
    notifyListeners();
  }

  /// Pull-to-refresh
  Future<void> refresh() async {
    await fetchEmployees();
  }

  /// Internal filter processor
  void _applyFilters() {
    _filteredEmployees = _allEmployees.where((employee) {
      // 1. Department Filter
      if (_selectedDepartment != 'All' &&
          employee.department.toLowerCase() != _selectedDepartment.toLowerCase()) {
        return false;
      }

      // 2. Status Filter
      if (_selectedStatus != null && employee.status != _selectedStatus) {
        return false;
      }

      // 3. Search Keyword Filter
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
  }
}
