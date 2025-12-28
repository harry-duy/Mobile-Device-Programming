import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart'; // Import để lấy Enum UserRole
import 'costomer_app/screens/login_screen.dart';
import 'costomer_app/main_customer.dart';
import 'admin_app/screens/admin_home_screen.dart'; // Import Admin Screen

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProfile = authProvider.userProfile; // Lấy thông tin role

    if (authProvider.user != null) {
      // Đã đăng nhập, kiểm tra Role
      if (userProfile != null && userProfile.role == UserRole.admin) {
        return const AdminHomeScreen(); // Admin -> Vào trang quản trị
      } else {
        return const MainCustomerScreen(); // Khách -> Vào trang bán hàng
      }
    } else {
      return const LoginScreen();
    }
  }
}