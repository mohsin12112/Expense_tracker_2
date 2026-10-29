import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'expense_model.dart';
import 'expense_chart_helper.dart';

class ExpensePieChartWidget extends StatefulWidget {
  final List<Expense> expenses;

  const ExpensePieChartWidget({super.key, required this.expenses});

  @override
  State<ExpensePieChartWidget> createState() => _ExpensePieChartWidgetState();
}

class _ExpensePieChartWidgetState extends State<ExpensePieChartWidget> {
  int touchedIndex = -1;

  final Map<String, Color> categoryColors = const {
    'Food': Colors.orange,
    'Travel': Colors.blue,
    'Shopping': Colors.purple,
    'Bills': Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    final summaries = ExpenseChartHelper.aggregateByCategory(widget.expenses);

    if (summaries.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalSpent = summaries.fold(0.0, (sum, item) => sum + item.totalAmount);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Category Breakdown",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 3,
                  centerSpaceRadius: 40,
                  sections: List.generate(summaries.length, (i) {
                    final isTouched = i == touchedIndex;
                    final fontSize = isTouched ? 18.0 : 12.0;
                    final radius = isTouched ? 60.0 : 50.0;
                    final item = summaries[i];
                    final percentage = ((item.totalAmount / totalSpent) * 100).toStringAsFixed(0);

                    return PieChartSectionData(
                      color: categoryColors[item.category] ?? Colors.teal,
                      value: item.totalAmount,
                      title: '$percentage%',
                      radius: radius,
                      titleStyle: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: summaries.map((item) {
                final color = categoryColors[item.category] ?? Colors.teal;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${item.category} (${item.totalAmount.toInt()} PKR)",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}