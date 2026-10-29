import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'expense_cubit.dart';

class BudgetCardWidget extends StatelessWidget {
  const BudgetCardWidget({super.key});

  void _showEditBudgetDialog(BuildContext context, double currentBudget) {
    final controller = TextEditingController(text: currentBudget.toInt().toString());

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Edit Monthly Budget"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Target Budget (PKR)",
              prefixIcon: const Icon(Icons.account_balance_wallet),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final newBudget = double.tryParse(controller.text.trim());
                if (newBudget != null && newBudget > 0) {
                  context.read<ExpenseCubit>().updateMonthlyBudget(newBudget);
                  Navigator.pop(dialogContext);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid budget amount.')),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        if (state is! ExpenseLoaded) return const SizedBox.shrink();

        final totalSpent = state.totalExpense;
        final budget = state.monthlyBudget;
        final progress = state.budgetProgress;

        // Dynamic progress color indicator
        Color progressColor = Colors.teal;
        if (progress >= 0.9) {
          progressColor = Colors.redAccent;
        } else if (progress >= 0.75) {
          progressColor = Colors.orangeAccent;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Monthly Budget",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      // Edit Button Icon
                      InkWell(
                        onTap: () => _showEditBudgetDialog(context, budget),
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "${totalSpent.toInt()} / ${budget.toInt()} PKR",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}