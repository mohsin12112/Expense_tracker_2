import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'expense_model.dart';

class ExpenseRepository {
  static const String _storageKey = 'expense_key';

  Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString(_storageKey);

    if (savedData == null) return [];

    final List<dynamic> decoded = jsonDecode(savedData);
    return decoded
        .map((item) => Expense.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      expenses.map((e) => e.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }
}