import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/error_banner.dart';
import '../widgets/primary_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอก username'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอก password'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authController = context.read<AuthController>();
    final success = await authController.login(username, password);

    if (!mounted) return;

    if (success) {
      final admin = authController.currentAdmin;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'เข้าสู่ระบบสำเร็จ! ยินดีต้อนรับ ${admin?.name ?? username}',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/render-list');
    } else {
      final errorMessage =
          authController.errorMessage ?? 'เข้าสู่ระบบไม่สำเร็จ';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = context.watch<AuthController>();
    final isLoading = authController.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              Text(
                'Login Render List',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 50),

              // คอมโพเนนต์แจ้งเตือน Error
              if (authController.errorMessage != null)
                ErrorBanner(
                  message: authController.errorMessage!,
                  onClose: authController.clearError,
                ),

              // คอมโพเนนต์ช่องกรอก Username
              CustomTextField(
                controller: _usernameController,
                label: 'username',
                hint: 'กรุณากรอก username',
                prefixIcon: Icons.person,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 24),

              // คอมโพเนนต์ช่องกรอก Password พร้อมปุ่มเปิด/ปิดการมองเห็น
              CustomTextField(
                controller: _passwordController,
                label: 'password',
                hint: 'กรุณากรอก password',
                prefixIcon: Icons.lock,
                obscureText: _obscurePassword,
                enabled: !isLoading,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleLogin(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 36),

              // คอมโพเนนต์ปุ่ม Login
              PrimaryButton(
                text: 'Login',
                isLoading: isLoading,
                onPressed: _handleLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
