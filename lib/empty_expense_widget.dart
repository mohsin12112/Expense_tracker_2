import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'expense_form.dart';
import 'expense_cubit.dart';
import 'expense_model.dart';

class EmptyExpenseWidget extends StatelessWidget {
  const EmptyExpenseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 56,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "No Expenses Recorded",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Start tracking your daily finances by adding your first transaction below.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final result = await Navigator.push<Expense>(
                  context,
                  MaterialPageRoute(builder: (_) => const ExpenseForm()),
                );
                if (result != null && context.mounted) {
                  context.read<ExpenseCubit>().addExpense(result);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("Add First Expense"),
            ),
          ],
        ),
      ),
    );
  }
}