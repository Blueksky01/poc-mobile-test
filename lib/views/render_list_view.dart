import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../widgets/admin_profile_card.dart';

class RenderListView extends StatefulWidget {
  const RenderListView({super.key});

  @override
  State<RenderListView> createState() => _RenderListViewState();
}

class _RenderListViewState extends State<RenderListView> {
  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final admin = authController.currentAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Render list'),
        actions: [
          if (admin != null)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                context.read<AuthController>().logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: admin != null
              ? AdminProfileCard(admin: admin)
              : const Text('Render list screen (ยังไม่ได้เข้าสู่ระบบ)'),
        ),
      ),
    );
  }
}