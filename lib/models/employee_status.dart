import 'package:flutter/material.dart';

enum EmployeeStatus {
  active('Active', 'ปฏิบัติงานปกติ'),
  inactive('Inactive', 'พ้นสภาพ / ไม่ได้ปฏิบัติงาน'),
  onLeave('On Leave', 'อยู่ระหว่างลา'),
  unknown('Unknown', 'ไม่ระบุสถานะ');

  final String rawValue;
  final String thaiLabel;

  const EmployeeStatus(this.rawValue, this.thaiLabel);

  /// Safe deserialization from String with case-insensitive matching
  factory EmployeeStatus.fromString(String? value) {
    if (value == null) return EmployeeStatus.unknown;
    final normalized = value.trim().toLowerCase();

    switch (normalized) {
      case 'active':
        return EmployeeStatus.active;
      case 'inactive':
        return EmployeeStatus.inactive;
      case 'on leave':
      case 'onleave':
        return EmployeeStatus.onLeave;
      default:
        return EmployeeStatus.unknown;
    }
  }

  /// Badge primary text color
  Color get textColor {
    switch (this) {
      case EmployeeStatus.active:
        return const Color(0xFF2E7D32); // Dark Green
      case EmployeeStatus.inactive:
        return const Color(0xFFC62828); // Dark Red
      case EmployeeStatus.onLeave:
        return const Color(0xFFE65100); // Dark Orange
      case EmployeeStatus.unknown:
        return const Color(0xFF616161); // Grey
    }
  }

  /// Badge background pastel tint
  Color get backgroundColor {
    switch (this) {
      case EmployeeStatus.active:
        return const Color(0xFFE8F5E9); // Light Green
      case EmployeeStatus.inactive:
        return const Color(0xFFFFEBEE); // Light Red
      case EmployeeStatus.onLeave:
        return const Color(0xFFFFF3E0); // Light Orange
      case EmployeeStatus.unknown:
        return const Color(0xFFF5F5F5); // Light Grey
    }
  }

  /// Badge border line color
  Color get borderColor {
    switch (this) {
      case EmployeeStatus.active:
        return const Color(0xFFA5D6A7);
      case EmployeeStatus.inactive:
        return const Color(0xFFEF9A9A);
      case EmployeeStatus.onLeave:
        return const Color(0xFFFFCC80);
      case EmployeeStatus.unknown:
        return const Color(0xFFE0E0E0);
    }
  }
}
