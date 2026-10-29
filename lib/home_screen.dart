import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'expense_cubit.dart';
import 'expense_model.dart';
import 'expense_repository.dart';
import 'expense_form.dart';
import 'expense_chart_widget.dart';
import 'theme_cubit.dart';
import 'expense_export_service.dart';
import 'budget_card_widget.dart';
import 'empty_expense_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExpenseCubit(ExpenseRepository()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          // Export Menu Button (CSV / PDF)
          BlocBuilder<ExpenseCubit, ExpenseState>(
            builder: (context, state) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.ios_share),
                tooltip: 'Export Report',
                onSelected: (option) async {
                  if (state is! ExpenseLoaded || state.allExpenses.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No expense records available to export.'),
                      ),
                    );
                    return;
                  }

                  if (option == 'pdf') {
                    await ExpenseExportService.exportToPDF(state.filteredExpenses);
                  } else if (option == 'csv') {
                    final file =
                    await ExpenseExportService.exportToCSV(state.filteredExpenses);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('CSV saved to: ${file.path}')),
                      );
                    }
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'pdf',
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Export as PDF'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'csv',
                    child: Row(
                      children: [
                        Icon(Icons.table_chart, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Export as CSV'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Theme Switcher Icon
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final isDark = themeMode == ThemeMode.dark ||
                  (themeMode == ThemeMode.system &&
                      MediaQuery.of(context).platformBrightness == Brightness.dark);

              return IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme(!isDark);
                },
              );
            },
          ),

          // Sort Menu Button
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort Expenses',
            onSelected: (sort) {
              context.read<ExpenseCubit>().updateSortOption(sort);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: SortOption.newest,
                child: Text('Date: Newest First'),
              ),
              PopupMenuItem(
                value: SortOption.oldest,
                child: Text('Date: Oldest First'),
              ),
              PopupMenuItem(
                value: SortOption.amountHighToLow,
                child: Text('Amount: High to Low'),
              ),
              PopupMenuItem(
                value: SortOption.amountLowToHigh,
                child: Text('Amount: Low to High'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Total Spent Card
          BlocBuilder<ExpenseCubit, ExpenseState>(
            builder: (context, state) {
              final total =
              state is ExpenseLoaded ? state.totalExpense.toInt() : 0;
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF004D40), Color(0xFF00796B)],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Spent",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    Text(
                      "$total PKR",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Monthly Target Budget Limits Progress Bar Card
          const BudgetCardWidget(),

          // Search Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search expense title...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (query) {
                context.read<ExpenseCubit>().updateSearchQuery(query);
              },
            ),
          ),

          // Category Chips
          BlocBuilder<ExpenseCubit, ExpenseState>(
            builder: (context, state) {
              final selectedCategory =
              state is ExpenseLoaded ? state.selectedCategory : 'All';
              final categories = ['All', 'Food', 'Travel', 'Shopping', 'Bills'];

              return SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = selectedCategory == cat;

                    return FilterChip(
                      selected: isSelected,
                      label: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF004D40)
                              : Colors.black87,
                          fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Colors.white,
                      selectedColor:
                      const Color(0xFF004D40).withValues(alpha: 0.15),
                      checkmarkColor: const Color(0xFF004D40),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF004D40)
                            : Colors.grey.shade300,
                      ),
                      onSelected: (_) {
                        context.read<ExpenseCubit>().updateCategoryFilter(cat);
                      },
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Transactions List, Chart & Empty State Handling
          Expanded(
            child: BlocBuilder<ExpenseCubit, ExpenseState>(
              builder: (context, state) {
                if (state is ExpenseLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ExpenseError) {
                  return Center(child: Text(state.message));
                }

                if (state is! ExpenseLoaded || state.filteredExpenses.isEmpty) {
                  // Renders the modern Empty Expense CTA Widget
                  return const EmptyExpenseWidget();
                }

                final expenses = state.filteredExpenses;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Visual Chart Widget using all expenses state
                      ExpensePieChartWidget(expenses: state.allExpenses),

                      const Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Text(
                          "Transactions",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: expenses.length,
                        itemBuilder: (ctx, index) {
                          final item = expenses[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: ListTile(
                              onTap: () =>
                                  _showOptionsDialog(context, index, item),
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                child: Text(
                                  item.category.isNotEmpty
                                      ? item.category[0].toUpperCase()
                                      : '?',
                                ),
                              ),
                              title: Text(item.title),
                              subtitle: Text(
                                "${item.date.day}/${item.date.month}/${item.date.year}",
                              ),
                              trailing: Text(
                                "${item.amount.toInt()} PKR",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (fabContext) {
          return FloatingActionButton(
            backgroundColor: const Color(0xFF00C853),
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push<Expense>(
                fabContext,
                MaterialPageRoute(builder: (_) => const ExpenseForm()),
              );

              if (result != null && fabContext.mounted) {
                fabContext.read<ExpenseCubit>().addExpense(result);
              }
            },
          );
        },
      ),
    );
  }

  void _showOptionsDialog(
      BuildContext parentContext, int index, Expense existingExpense) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Options"),
          content: const Text("Choose an action"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                parentContext.read<ExpenseCubit>().deleteExpense(index);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final result = await Navigator.push<Expense>(
                  parentContext,
                  MaterialPageRoute(
                    builder: (_) =>
                        ExpenseForm(existingExpense: existingExpense),
                  ),
                );

                if (result != null && parentContext.mounted) {
                  parentContext.read<ExpenseCubit>().updateExpense(result);
                }
              },
              child: const Text("Edit"),
            ),
          ],
        );
      },
    );
  }
}