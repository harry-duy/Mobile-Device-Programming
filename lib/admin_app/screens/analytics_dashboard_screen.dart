import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/firebase_service.dart';
import 'package:intl/intl.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  final FirebaseService _service = FirebaseService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _service.getOrderStatistics();
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text("Thống kê & Báo cáo")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(),
            const SizedBox(height: 20),
            const Text("Trạng thái đơn hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildStatusChart(),
            const SizedBox(height: 20),
            const Text("Doanh thu theo thời gian", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildRevenueChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            "Tổng đơn hàng",
            _stats['totalOrders'].toString(),
            Icons.shopping_cart,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            "Doanh thu",
            "${NumberFormat.compact().format(_stats['totalRevenue'])} VND",
            Icons.attach_money,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChart() {
    Map<String, int> statusCount = Map<String, int>.from(_stats['statusCount'] ?? {});
    if (statusCount.isEmpty) return const Center(child: Text("Không có dữ liệu"));

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: statusCount.entries.map((e) {
            return PieChartSectionData(
              value: e.value.toDouble(),
              title: "${e.key}\n${e.value}",
              radius: 50,
              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    // Giả lập dữ liệu doanh thu theo ngày
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 3),
                const FlSpot(1, 1),
                const FlSpot(2, 4),
                const FlSpot(3, 2),
                const FlSpot(4, 5),
              ],
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
            ),
          ],
        ),
      ),
    );
  }
}
