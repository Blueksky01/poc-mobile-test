import 'package:flutter/material.dart';
import '../models/admin_model.dart';

class AdminProfileCard extends StatelessWidget {
  final AdminUser admin;

  const AdminProfileCard({
    super.key,
    required this.admin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.admin_panel_settings,
          size: 80,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        Text(
          'เข้าสู่ระบบสำเร็จ!',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.green.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ชื่อ: ${admin.name}',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Username: ${admin.username}',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Role: ${admin.role}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
