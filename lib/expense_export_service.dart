import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'expense_model.dart';

class ExpenseExportService {
  /// Generates a CSV file from expenses and saves it locally
  static Future<File> exportToCSV(List<Expense> expenses) async {
    final List<List<dynamic>> rows = [
      ['ID', 'Title', 'Amount (PKR)', 'Category', 'Date'],
    ];

    for (final e in expenses) {
      rows.add([
        e.id,
        e.title,
        e.amount,
        e.category,
        "${e.date.day}/${e.date.month}/${e.date.year}",
      ]);
    }

    // Pure Dart CSV Converter (zero dependency issues)
    final String csvData = rows.map((row) {
      return row.map((field) => '"${field.toString().replaceAll('"', '""')}"').join(',');
    }).join('\n');

    final directory = await getApplicationDocumentsDirectory();
    final String filePath = "${directory.path}/expenses_report_${DateTime.now().millisecondsSinceEpoch}.csv";
    final file = File(filePath);

    return await file.writeAsString(csvData);
  }

  /// Generates a PDF Financial Report and opens the system print/share preview
  static Future<void> exportToPDF(List<Expense> expenses) async {
    final pdf = pw.Document();

    final totalSpent = expenses.fold(0.0, (sum, item) => sum + item.amount);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header Title
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'EXPENSE REPORT',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal900,
                      ),
                    ),
                    pw.Text(
                      'Generated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: const pw.TextStyle(color: PdfColors.grey700),
                    ),
                  ],
                ),
                pw.Divider(thickness: 2, color: PdfColors.teal900),
                pw.SizedBox(height: 16),

                // Summary Total Box
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.teal50,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.teal),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total Expenses:',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '${totalSpent.toInt()} PKR',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red800,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Transactions Table
                pw.Table.fromTextArray(
                  headers: ['Category', 'Title', 'Date', 'Amount (PKR)'],
                  data: expenses.map((e) {
                    return [
                      e.category,
                      e.title,
                      "${e.date.day}/${e.date.month}/${e.date.year}",
                      "${e.amount.toInt()} PKR",
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.teal900),
                  cellAlignment: pw.Alignment.centerLeft,
                  rowDecoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Open native print & preview dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Expense_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}