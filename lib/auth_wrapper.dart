import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'costomer_app/screens/login_screen.dart';
// --- SỬA DÒNG NÀY ---
import 'costomer_app/main_customer.dart'; // Đổi tên file cho đúng với cột bên trái

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.user != null) {
      // Đã đăng nhập -> Vào màn hình chính (Có menu dưới đáy)
      return const MainCustomerScreen();
    } else {
      // Chưa đăng nhập -> Vào màn hình Login
      return const LoginScreen();
    }
  }
}