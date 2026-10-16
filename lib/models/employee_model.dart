import 'package:flutter/material.dart';
import 'address_model.dart';
import 'employee_status.dart';

class EmployeeModel {
  final String id;
  final String name;
  final String email;
  final String department;
  final EmployeeStatus status;
  final AddressModel address;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.status,
    required this.address,
  });

  /// Factory constructor สำหรับแปลง JSON ให้อยู่ในรูปแบบ EmployeeModel ที่มี type ชัดเจน
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: (json['id'] as String?)?.trim() ?? '',
      name: (json['name'] as String?)?.trim() ?? 'ไม่ระบุชื่อ',
      email: (json['email'] as String?)?.trim() ?? '-',
      department: (json['department'] as String?)?.trim() ?? 'ทั่วไป',
      status: EmployeeStatus.fromString(json['status'] as String?),
      address: AddressModel.fromJson(
        json['address'] as Map<String, dynamic>?,
      ),
    );
  }

  /// แปลง EmployeeModel เป็น Map เพื่อนำไปแปลงเป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
      'status': status.rawValue,
      'address': address.toJson(),
    };
  }

  /// ตัวอักษรตัวแรกของชื่อพนักงานสำหรับแสดงผลใน Avatar
  String get nameInitial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    // ดึงตัวอักษรตัวแรกที่มองเห็น (รองรับภาษาไทย)
    return trimmed.characters.first;
  }

  /// สีธีมประจำแผนกตามชื่อแผนก
  Color get departmentThemeColor {
    final dept = department.toLowerCase();
    if (dept.contains('engine')) return const Color(0xFF1565C0); // สีน้ำเงิน
    if (dept.contains('human') || dept.contains('hr')) return const Color(0xFF6A1B9A); // สีม่วง
    if (dept.contains('finan')) return const Color(0xFF2E7D32); // สีเขียว
    if (dept.contains('market')) return const Color(0xFFC2185B); // สีชมพู
    if (dept.contains('sale')) return const Color(0xFFEF6C00); // สีส้ม
    if (dept.contains('support')) return const Color(0xFF00838F); // สีเขียวน้ำทะเล
    if (dept.contains('design')) return const Color(0xFF7B1FA2); // สีม่วงเข้ม
    if (dept.contains('product')) return const Color(0xFFD84315); // สีส้มเข้ม
    if (dept.contains('operat')) return const Color(0xFF455A64); // สีเทาอมฟ้า
    return const Color(0xFF424242);
  }
}
