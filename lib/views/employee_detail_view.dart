import 'package:flutter/material.dart';
import '../components/employee_avatar.dart';
import '../components/status_badge.dart';
import '../models/employee_model.dart';

class EmployeeDetailView extends StatelessWidget {
  final EmployeeModel employee;

  const EmployeeDetailView({
    super.key,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อมูลพนักงาน'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    EmployeeAvatar(employee: employee, radius: 40),
                    const SizedBox(height: 12),
                    Text(
                      employee.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.id,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StatusBadge(status: employee.status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Work Details Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ข้อมูลการทำงานและการติดต่อ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.business,
                      label: 'แผนก',
                      value: employee.department,
                      valueColor: employee.departmentThemeColor,
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: 'อีเมล',
                      value: employee.email,
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      icon: Icons.badge_outlined,
                      label: 'สถานะ',
                      value: '${employee.status.rawValue} (${employee.status.thaiLabel})',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Address Details Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ข้อมูลที่อยู่',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.home_outlined,
                      label: 'ถนน / ซอย',
                      value: employee.address.street,
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      icon: Icons.map_outlined,
                      label: 'ตำบล / แขวง',
                      value: employee.address.subdistrict,
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      icon: Icons.location_city_outlined,
                      label: 'อำเภอ / เขต',
                      value: employee.address.district,
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      icon: Icons.public_outlined,
                      label: 'จังหวัด',
                      value: employee.address.province,
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      icon: Icons.markunread_mailbox_outlined,
                      label: 'รหัสไปรษณีย์',
                      value: employee.address.postalCode,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.pin_drop_outlined,
                      label: 'ที่อยู่รวม',
                      value: employee.address.formattedAddress,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade500),
        const SizedBox(width: 12),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: valueColor ?? const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}
