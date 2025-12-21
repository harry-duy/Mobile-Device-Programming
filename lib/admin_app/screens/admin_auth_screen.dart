import 'package:flutter/material.dart';

class AdminAuthScreen extends StatelessWidget {
  const AdminAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Login"), backgroundColor: Colors.blueGrey),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TextField(decoration: InputDecoration(labelText: "Admin Email")),
            const TextField(decoration: InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              onPressed: () {
                // Thêm logic đăng nhập admin tại đây
              },
              child: const Text("Đăng nhập hệ thống", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}