import 'expense_model.dart';

class CategorySummary {
  final String category;
  final double totalAmount;

  CategorySummary({required this.category, required this.totalAmount});
}

class ExpenseChartHelper {
  /// Aggregates expenses by category for pie chart rendering
  static List<CategorySummary> aggregateByCategory(List<Expense> expenses) {
    final Map<String, double> categoryMap = {};

    for (final expense in expenses) {
      categoryMap[expense.category] =
          (categoryMap[expense.category] ?? 0.0) + expense.amount;
    }

    return categoryMap.entries
        .map((e) => CategorySummary(category: e.key, totalAmount: e.value))
        .toList();
  }
}