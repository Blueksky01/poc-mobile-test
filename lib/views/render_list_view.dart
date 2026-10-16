import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/empty_state_view.dart';
import '../components/error_state_view.dart';
import '../components/employee_card.dart';
import '../components/loading_skeleton.dart';
import '../components/pagination_bar.dart';
import '../components/search_filter_bar.dart';
import '../controllers/auth_controller.dart';
import '../controllers/employee_controller.dart';
import 'employee_detail_view.dart';

class RenderListView extends StatefulWidget {
  const RenderListView({super.key});

  @override
  State<RenderListView> createState() => _RenderListViewState();
}

class _RenderListViewState extends State<RenderListView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // ตรวจสอบสิทธิ์การเข้าใช้งาน: ต้อง Login ก่อนเข้าถึงหน้านี้
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authController = context.read<AuthController>();
      if (!authController.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final controller = context.read<EmployeeController>();
      if (controller.employees.isEmpty && !controller.isLoading) {
        controller.fetchEmployees();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final admin = authController.currentAdmin;
    final employeeController = context.watch<EmployeeController>();

    // หากยังไม่ Login ให้แสดงสถานะโหลดเพื่อรอการเปลี่ยนเส้นทางกลับหน้า Login
    if (!authController.isAuthenticated) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'รายชื่อพนักงาน',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            if (!employeeController.isLoading)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  employeeController.searchQuery.isEmpty &&
                          employeeController.selectedDepartment == 'All'
                      ? '${employeeController.totalCount} คน'
                      : '${employeeController.filteredCount}/${employeeController.totalCount}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'รีเฟรชข้อมูล',
            onPressed: employeeController.isLoading
                ? null
                : () => employeeController.refresh(),
          ),
          if (admin != null)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'ออกจากระบบ',
              onPressed: () {
                context.read<AuthController>().logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // แถบค้นหาและตัวกรองแผนก (Search & Department Filter Chips)
          SearchFilterBar(
            searchQuery: employeeController.searchQuery,
            selectedDepartment: employeeController.selectedDepartment,
            departments: employeeController.availableDepartments,
            onSearchChanged: (query) => employeeController.setSearchQuery(query),
            onDepartmentSelected: (dept) => employeeController.setDepartment(dept),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // รายการข้อมูลตามสถานะ (UI State Handler)
          Expanded(
            child: _buildBody(context, employeeController),
          ),

          // ส่วนควบคุมการแบ่งหน้า (Pagination Controls: แบ่งทีละ 10 รายการต่อหน้า)
          if (!employeeController.isLoading &&
              employeeController.errorMessage == null &&
              employeeController.filteredEmployees.isNotEmpty)
            PaginationBar(
              currentPage: employeeController.currentPage,
              totalPages: employeeController.totalPages,
              totalItems: employeeController.filteredCount,
              startIndex: employeeController.startIndex,
              endIndex: employeeController.endIndex,
              onPageChanged: (page) {
                employeeController.setPage(page);
                _scrollToTop();
              },
              onPrevious: () {
                employeeController.previousPage();
                _scrollToTop();
              },
              onNext: () {
                employeeController.nextPage();
                _scrollToTop();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, EmployeeController controller) {
    // 1. สถานะ Loading: แสดง Shimmer Skeleton
    if (controller.isLoading) {
      return const LoadingSkeleton();
    }

    // 2. สถานะ Error: แสดงข้อความ Error พร้อมปุ่มกดลองใหม่ (Retry)
    if (controller.errorMessage != null) {
      return ErrorStateView(
        errorMessage: controller.errorMessage!,
        onRetry: () => controller.fetchEmployees(),
      );
    }

    // 3. สถานะ Empty: ค้นหาหรือกรองแล้วไม่พบข้อมูล
    if (controller.filteredCount == 0) {
      return EmptyStateView(
        onClearFilter: () => controller.clearFilters(),
      );
    }

    // 4. สถานะ Success: แสดง List รายการพนักงาน พร้อม Pull-to-Refresh
    return RefreshIndicator(
      onRefresh: () => controller.refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: controller.employees.length,
        itemBuilder: (context, index) {
          final employee = controller.employees[index];

          return EmployeeCard(
            key: ValueKey(employee.id),
            employee: employee,
            onTap: () {
              // [Navigator] นำทางไปยังหน้ารายละเอียดพนักงาน
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EmployeeDetailView(employee: employee),
                ),
              );
            },
          );
        },
      ),
    );
  }
}