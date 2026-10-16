import 'package:flutter/material.dart';

enum EmployeeStatus {
  active('Active', 'ปฏิบัติงานปกติ'),
  inactive('Inactive', 'พ้นสภาพ / ไม่ได้ปฏิบัติงาน'),
  onLeave('On Leave', 'อยู่ระหว่างลา'),
  unknown('Unknown', 'ไม่ระบุสถานะ');

  final String rawValue;
  final String thaiLabel;

  const EmployeeStatus(this.rawValue, this.thaiLabel);

  /// แปลง String เป็น EmployeeStatus อย่างปลอดภัย โดยไม่สนใจตัวพิมพ์เล็ก-ใหญ่ (case-insensitive)
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

  /// สีข้อความหลักของป้ายสถานะ (Badge)
  Color get textColor {
    switch (this) {
      case EmployeeStatus.active:
        return const Color(0xFF2E7D32); // สีเขียวเข้ม
      case EmployeeStatus.inactive:
        return const Color(0xFFC62828); // สีแดงเข้ม
      case EmployeeStatus.onLeave:
        return const Color(0xFFE65100); // สีส้มเข้ม
      case EmployeeStatus.unknown:
        return const Color(0xFF616161); // สีเทา
    }
  }

  /// สีพื้นหลังโทนพาสเทลของป้ายสถานะ (Badge)
  Color get backgroundColor {
    switch (this) {
      case EmployeeStatus.active:
        return const Color(0xFFE8F5E9); // สีเขียวอ่อน
      case EmployeeStatus.inactive:
        return const Color(0xFFFFEBEE); // สีแดงอ่อน
      case EmployeeStatus.onLeave:
        return const Color(0xFFFFF3E0); // สีส้มอ่อน
      case EmployeeStatus.unknown:
        return const Color(0xFFF5F5F5); // สีเทาอ่อน
    }
  }

  /// สีกรอบของป้ายสถานะ (Badge)
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
