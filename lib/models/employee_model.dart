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

  /// Factory constructor to map raw JSON to typed EmployeeModel
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

  /// Serialize EmployeeModel to JSON map
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

  /// First character of employee name for Avatar display
  String get nameInitial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    // Get first visible grapheme/character
    return trimmed.characters.first;
  }

  /// Consistent theme color based on department name
  Color get departmentThemeColor {
    final dept = department.toLowerCase();
    if (dept.contains('engine')) return const Color(0xFF1565C0); // Blue
    if (dept.contains('human') || dept.contains('hr')) return const Color(0xFF6A1B9A); // Purple
    if (dept.contains('finan')) return const Color(0xFF2E7D32); // Green
    if (dept.contains('market')) return const Color(0xFFC2185B); // Pink
    if (dept.contains('sale')) return const Color(0xFFEF6C00); // Orange
    if (dept.contains('support')) return const Color(0xFF00838F); // Teal
    if (dept.contains('design')) return const Color(0xFF7B1FA2); // Deep Purple
    if (dept.contains('product')) return const Color(0xFFD84315); // Deep Orange
    if (dept.contains('operat')) return const Color(0xFF455A64); // Blue Grey
    return const Color(0xFF424242);
  }
}
