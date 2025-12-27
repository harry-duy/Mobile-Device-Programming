import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'costomer_app/main_customer.dart' as customer;
import 'admin_app/main_admin.dart' as admin;

import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'costomer_app/screens/login_screen.dart';
import 'costomer_app/screens/customer_home_screen.dart';
import 'admin_app/screens/admin_home_screen.dart';
import 'splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Delivery System',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const RoleSelectionScreen(),
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo hoặc Icon
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.delivery_dining,
                    size: 80,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Food Delivery System',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Chọn vai trò của bạn',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 60),

                // Nút Customer
                _buildRoleButton(
                  context: context,
                  icon: Icons.shopping_bag,
                  title: 'Khách hàng',
                  subtitle: 'Đặt món ăn yêu thích',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const customer.CustomerApp(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Nút Admin
                _buildRoleButton(
                  context: context,
                  icon: Icons.admin_panel_settings,
                  title: 'Quản trị viên',
                  subtitle: 'Quản lý đơn hàng & giao hàng',
                  color: Colors.blueGrey,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const admin.AdminApp(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color),
          ],
        ),
      ),
=======
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Food Delivery System',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          useMaterial3: true,
        ),
        home: const SplashScreen(), // <--- Sửa dòng này
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.status == AuthStatus.uninitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.isAuthenticated) {
          // 2. THÊM LOGIC KIỂM TRA QUYỀN ADMIN
          if (authProvider.isAdmin) {
            return const AdminHomeScreen();
          }
          return const CustomerHomeScreen();
        }

        return const LoginScreen();
      },

    );
  }
}