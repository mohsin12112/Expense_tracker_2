import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../lib/expense_cubit.dart';
import '../lib/expense_model.dart';
import 'mock_expense_repository.dart';

void main() {
  late MockExpenseRepository mockRepository;

  final testExpense = Expense(
    id: '1',
    title: 'Dinner',
    amount: 1500.0,
    category: 'Food',
    date: DateTime(2026, 10, 28),
  );

  setUpAll(() {
    registerFallbackValue(<Expense>[]);
  });

  setUp(() {
    mockRepository = MockExpenseRepository();
  });

  group('ExpenseCubit Tests', () {
    test('Initial state is ExpenseLoading before async initialization completes', () {
      when(() => mockRepository.loadExpenses()).thenAnswer((_) async => []);
      final cubit = ExpenseCubit(mockRepository);

      // Verify initial state sync
      expect(cubit.state, isA<ExpenseLoading>());
    });

    blocTest<ExpenseCubit, ExpenseState>(
      'Emits [ExpenseLoaded] when loadExpenses completes on initialization',
      build: () {
        when(() => mockRepository.loadExpenses()).thenAnswer((_) async => [testExpense]);
        return ExpenseCubit(mockRepository);
      },
      expect: () => [
        isA<ExpenseLoaded>().having(
              (state) => state.allExpenses.length,
          'allExpenses length',
          1,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.loadExpenses()).called(1);
      },
    );

    blocTest<ExpenseCubit, ExpenseState>(
      'Adds an expense and emits updated ExpenseLoaded state',
      build: () {
        when(() => mockRepository.loadExpenses()).thenAnswer((_) async => []);
        when(() => mockRepository.saveExpenses(any())).thenAnswer((_) async => {});
        return ExpenseCubit(mockRepository);
      },
      act: (cubit) async {
        // Wait for initial constructor load to settle before calling addExpense
        await Future.delayed(Duration.zero);
        await cubit.addExpense(testExpense);
      },
      expect: () => [
        isA<ExpenseLoaded>().having((s) => s.allExpenses.length, 'empty initially', 0),
        isA<ExpenseLoaded>().having((s) => s.allExpenses.length, 'contains 1 item', 1),
      ],
      verify: (_) {
        verify(() => mockRepository.saveExpenses(any())).called(1);
      },
    );

    blocTest<ExpenseCubit, ExpenseState>(
      'Filters expenses correctly when category filter changes',
      build: () {
        when(() => mockRepository.loadExpenses()).thenAnswer((_) async => [
          testExpense,
          Expense(
            id: '2',
            title: 'Fuel',
            amount: 3000.0,
            category: 'Travel',
            date: DateTime(2026, 10, 28),
          ),
        ]);
        return ExpenseCubit(mockRepository);
      },
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.updateCategoryFilter('Food');
      },
      expect: () => [
        isA<ExpenseLoaded>().having((s) => s.filteredExpenses.length, 'unfiltered', 2),
        isA<ExpenseLoaded>().having((s) => s.filteredExpenses.length, 'filtered to Food', 1),
      ],
    );
  });
}