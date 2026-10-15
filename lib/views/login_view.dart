import 'package:flutter/material.dart';
import 'package:mypoc1/views/render_list_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        child: Column(
          children: [
            Text(
              'Login Render List',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 70),
            TextField(
              decoration: const InputDecoration(
                label: Text('username'),
                hint: Text('กรุณากรอก username'),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              decoration: const InputDecoration(
                label: Text('password'),
                hint: Text('กรุณากรอก password'),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed:() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)
                    => const RenderListView()
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                // กำหนด ขนาดปุ่ม ความกว้าง 200 และความสูง 60 (หน่วยเป็นพิกเซล)
                fixedSize: const Size(200, 60),
                backgroundColor: Colors.blue,// สีพื้นหลังของปุ่ม (Background Color)
                foregroundColor: Colors.black,// สีของข้อความและไอคอนบนปุ่ม (Text/Icon Color)
              ),
              child: Text('Login',
              style: theme.textTheme.titleLarge, 
                
              ),
            
            )
          ],
        ),
      ),
    );
  }
}
