import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// --- IMPORT CÁC PROVIDER ---
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart'; // Nếu bạn chưa có file này thì comment dòng này lại
import 'providers/theme_provider.dart'; // <--- Quan trọng để sửa lỗi màn hình đỏ

// --- IMPORT MÀN HÌNH ---
import 'splash_screen.dart'; // Màn hình chờ (đã tạo ở các bước trước)

void main() async {
  // 1. Khởi tạo Flutter Binding
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo Firebase (Kết nối Database)
  await Firebase.initializeApp();

  // 3. Chạy ứng dụng
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. Bọc toàn bộ ứng dụng trong MultiProvider
    // Giúp tất cả các màn hình con đều truy cập được dữ liệu (Auth, Cart, Theme)
    return MultiProvider(
      providers: [
        // Provider quản lý Đăng nhập/Đăng ký
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Provider quản lý Giỏ hàng (Member 1 làm)
        ChangeNotifierProvider(create: (_) => CartProvider()),

        // Provider quản lý Giao diện Sáng/Tối (Sửa lỗi màn hình đỏ tại đây)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const AppContent(),
    );
  }
}

// Tách ra widget con để lắng nghe ThemeProvider
class AppContent extends StatelessWidget {
  const AppContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy theme từ Provider để cập nhật toàn bộ app
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Tắt chữ DEBUG ở góc phải
      title: 'Food Delivery System',

      // Thiết lập Theme (Sáng hoặc Tối) dựa trên cài đặt của người dùng
      theme: themeProvider.currentTheme,

      // Màn hình đầu tiên khi mở app
      home: const SplashScreen(),
    );
  }
}