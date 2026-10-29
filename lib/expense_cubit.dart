import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'expense_model.dart';
import 'expense_repository.dart';

enum SortOption { newest, oldest, amountHighToLow, amountLowToHigh }

sealed class ExpenseState {
  const ExpenseState();
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> allExpenses;
  final List<Expense> filteredExpenses;
  final String searchQuery;
  final String selectedCategory;
  final SortOption sortOption;
  final double monthlyBudget;

  const ExpenseLoaded({
    required this.allExpenses,
    required this.filteredExpenses,
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.sortOption = SortOption.newest,
    this.monthlyBudget = 50000.0,
  });

  double get totalExpense =>
      filteredExpenses.fold(0.0, (sum, item) => sum + item.amount);

  double get budgetProgress =>
      monthlyBudget > 0 ? (totalExpense / monthlyBudget).clamp(0.0, 1.0) : 0.0;
}

class ExpenseError extends ExpenseState {
  final String message;
  const ExpenseError(this.message);
}

class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseRepository _repository;

  ExpenseCubit(this._repository) : super(const ExpenseLoading()) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    emit(const ExpenseLoading());
    try {
      final expenses = await _repository.loadExpenses();

      // Read saved budget from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedBudget = prefs.getDouble('monthly_budget_key') ?? 50000.0;

      emit(ExpenseLoaded(
        allExpenses: expenses,
        filteredExpenses: _applyFilterAndSort(
          expenses: expenses,
          searchQuery: '',
          category: 'All',
          sort: SortOption.newest,
        ),
        searchQuery: '',
        selectedCategory: 'All',
        sortOption: SortOption.newest,
        monthlyBudget: savedBudget,
      ));
    } catch (e) {
      emit(ExpenseError('Failed to load expenses: ${e.toString()}'));
    }
  }

  void updateSearchQuery(String query) {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      _applyFilterAndEmit(
        allExpenses: currentState.allExpenses,
        searchQuery: query,
        selectedCategory: currentState.selectedCategory,
        sortOption: currentState.sortOption,
        monthlyBudget: currentState.monthlyBudget,
      );
    }
  }

  void updateCategoryFilter(String category) {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      _applyFilterAndEmit(
        allExpenses: currentState.allExpenses,
        searchQuery: currentState.searchQuery,
        selectedCategory: category,
        sortOption: currentState.sortOption,
        monthlyBudget: currentState.monthlyBudget,
      );
    }
  }

  void updateSortOption(SortOption sort) {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      _applyFilterAndEmit(
        allExpenses: currentState.allExpenses,
        searchQuery: currentState.searchQuery,
        selectedCategory: currentState.selectedCategory,
        sortOption: sort,
        monthlyBudget: currentState.monthlyBudget,
      );
    }
  }

  Future<void> addExpense(Expense expense) async {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      final updatedList = [expense, ...currentState.allExpenses];
      _applyFilterAndEmit(
        allExpenses: updatedList,
        searchQuery: currentState.searchQuery,
        selectedCategory: currentState.selectedCategory,
        sortOption: currentState.sortOption,
        monthlyBudget: currentState.monthlyBudget,
      );
      await _repository.saveExpenses(updatedList);
    }
  }

  Future<void> deleteExpense(int index) async {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      final itemToDelete = currentState.filteredExpenses[index];
      final updatedList = currentState.allExpenses
          .where((e) => e.id != itemToDelete.id)
          .toList();

      _applyFilterAndEmit(
        allExpenses: updatedList,
        searchQuery: currentState.searchQuery,
        selectedCategory: currentState.selectedCategory,
        sortOption: currentState.sortOption,
        monthlyBudget: currentState.monthlyBudget,
      );
      await _repository.saveExpenses(updatedList);
    }
  }

  Future<void> updateExpense(Expense updatedExpense) async {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      final updatedList = currentState.allExpenses.map((e) {
        return e.id == updatedExpense.id ? updatedExpense : e;
      }).toList();

      _applyFilterAndEmit(
        allExpenses: updatedList,
        searchQuery: currentState.searchQuery,
        selectedCategory: currentState.selectedCategory,
        sortOption: currentState.sortOption,
        monthlyBudget: currentState.monthlyBudget,
      );
      await _repository.saveExpenses(updatedList);
    }
  }

  Future<void> updateMonthlyBudget(double newBudget) async {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('monthly_budget_key', newBudget);

      _applyFilterAndEmit(
        allExpenses: currentState.allExpenses,
        searchQuery: currentState.searchQuery,
        selectedCategory: currentState.selectedCategory,
        sortOption: currentState.sortOption,
        monthlyBudget: newBudget,
      );
    }
  }

  List<Expense> _applyFilterAndSort({
    required List<Expense> expenses,
    required String searchQuery,
    required String category,
    required SortOption sort,
  }) {
    List<Expense> filtered = List.from(expenses);

    // 1. Filter by Category
    if (category != 'All') {
      filtered = filtered
          .where((e) => e.category.toLowerCase() == category.toLowerCase())
          .toList();
    }

    // 2. Search by Title Query
    if (searchQuery.trim().isNotEmpty) {
      filtered = filtered
          .where((e) => e.title.toLowerCase().contains(searchQuery.toLowerCase().trim()))
          .toList();
    }

    // 3. Sort List
    switch (sort) {
      case SortOption.newest:
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOption.oldest:
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOption.amountHighToLow:
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortOption.amountLowToHigh:
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return filtered;
  }

  void _applyFilterAndEmit({
    required List<Expense> allExpenses,
    required String searchQuery,
    required String selectedCategory,
    required SortOption sortOption,
    required double monthlyBudget,
  }) {
    final filtered = _applyFilterAndSort(
      expenses: allExpenses,
      searchQuery: searchQuery,
      category: selectedCategory,
      sort: sortOption,
    );

    emit(ExpenseLoaded(
      allExpenses: allExpenses,
      filteredExpenses: filtered,
      searchQuery: searchQuery,
      selectedCategory: selectedCategory,
      sortOption: sortOption,
      monthlyBudget: monthlyBudget,
    ));
  }
}