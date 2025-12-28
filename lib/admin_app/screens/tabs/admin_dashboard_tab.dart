import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;

        // 1. TÍNH TOÁN SỐ LIỆU
        double totalRevenue = 0;
        int totalOrders = docs.length;
        int pendingOrders = 0;
        int completedOrders = 0;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'];
          final price = (data['totalPrice'] ?? 0).toDouble();

          // Chỉ tính doanh thu đơn đã hoàn thành (hoặc tính hết tùy logic của bạn)
          if (status != 'cancelled') {
            totalRevenue += price;
          }

          if (status == 'pending') pendingOrders++;
          if (status == 'completed') completedOrders++;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tổng quan hôm nay", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // 2. HIỂN THỊ CÁC THẺ THỐNG KÊ (GRID)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true, // Quan trọng khi lồng trong ScrollView
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.4, // Chỉnh tỷ lệ thẻ cho đẹp
                children: [
                  _buildStatCard(
                    title: "Doanh thu",
                    value: "${NumberFormat("#,###").format(totalRevenue)}đ",
                    icon: Icons.monetization_on,
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    title: "Tổng đơn hàng",
                    value: "$totalOrders",
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    title: "Đang chờ duyệt",
                    value: "$pendingOrders",
                    icon: Icons.hourglass_top,
                    color: Colors.orange,
                  ),
                  _buildStatCard(
                    title: "Đã hoàn thành",
                    value: "$completedOrders",
                    icon: Icons.check_circle,
                    color: Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 3. BIỂU ĐỒ GIẢ (Dùng Progress Bar để mô phỏng tỷ lệ hoàn thành)
              const Text("Hiệu suất xử lý", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildProgressRow("Tỷ lệ hoàn thành", completedOrders, totalOrders, Colors.green),
              _buildProgressRow("Tỷ lệ chờ xử lý", pendingOrders, totalOrders, Colors.orange),
              _buildProgressRow("Tỷ lệ hủy (Giả định)", totalOrders - pendingOrders - completedOrders, totalOrders, Colors.red),
            ],
          ),
        );
      },
    );
  }

  // Widget Thẻ thống kê
  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  // Widget thanh tiến trình
  Widget _buildProgressRow(String label, int value, int total, Color color) {
    if (total == 0) return const SizedBox();
    double percent = value / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text("${(percent * 100).toStringAsFixed(1)}%", style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.grey.shade200,
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }
}