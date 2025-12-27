import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/models.dart';
import 'package:intl/intl.dart';

class ExportService {
  Future<String> exportOrdersToCSV(List<OrderModel> orders) async {
    List<List<dynamic>> rows = [];

    // Header
    rows.add([
      "Order ID",
      "Customer Name",
      "Phone",
      "Total Amount",
      "Status",
      "Order Date",
      "Address"
    ]);

    for (var order in orders) {
      rows.add([
        order.id,
        order.customerName,
        order.customerPhone,
        order.totalAmount,
        order.status.displayName,
        DateFormat('dd/MM/yyyy HH:mm').format(order.orderDate),
        order.deliveryAddress
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/orders_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);
    return file.path;
  }

  Future<String> exportOrdersToPDF(List<OrderModel> orders) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text("Order Report")),
          pw.TableHelper.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>['ID', 'Customer', 'Total', 'Status', 'Date'],
              ...orders.map((order) => [
                order.id.substring(0, 5),
                order.customerName,
                "${order.totalAmount.toInt()} VND",
                order.status.displayName,
                DateFormat('dd/MM/yy').format(order.orderDate)
              ])
            ],
          ),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/orders_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }
}
