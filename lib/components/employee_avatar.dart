import 'package:flutter/material.dart';
import '../models/employee_model.dart';

class EmployeeAvatar extends StatelessWidget {
  final EmployeeModel employee;
  final double radius;

  const EmployeeAvatar({
    super.key,
    required this.employee,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = employee.departmentThemeColor;

    return CircleAvatar(
      radius: radius,
      backgroundColor: themeColor.withValues(alpha: 0.15),
      child: Text(
        employee.nameInitial,
        style: TextStyle(
          color: themeColor,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.85,
        ),
      ),
    );
  }
}
