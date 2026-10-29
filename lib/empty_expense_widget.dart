import 'package:flutter/material.dart';
import 'expense_form.dart';
import 'expense_cubit.dart';
import 'expense_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmptyExpenseWidget extends StatelessWidget {
  const EmptyExpenseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 24),
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