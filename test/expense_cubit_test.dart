import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker_2/expense_cubit.dart';
import 'package:expense_tracker_2/expense_model.dart';
import 'package:expense_tracker_2/expense_repository.dart';
import 'mock_expense_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
    SharedPreferences.setMockInitialValues({});
    mockRepository = MockExpenseRepository();
  });

  group('ExpenseCubit Tests', () {
    test('Initial state is ExpenseLoading before constructor load completes', () {
      when(() => mockRepository.loadExpenses()).thenAnswer((_) async => []);
      final cubit = ExpenseCubit(mockRepository);

      expect(cubit.state, isA<ExpenseLoading>());
    });

    blocTest<ExpenseCubit, ExpenseState>(
      'Emits [ExpenseLoaded] when loadExpenses completes on initialization',
      build: () {
        when(() => mockRepository.loadExpenses()).thenAnswer((_) async => [testExpense]);
        return ExpenseCubit(mockRepository);
      },
      expect: () => [
        isA<ExpenseLoaded>()
            .having((s) => s.allExpenses.length, 'allExpenses length', 1)
            .having((s) => s.selectedCategory, 'category', 'All'),
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
        await pumpEventQueue();
        await cubit.addExpense(testExpense);
      },
      skip: 1,
      expect: () => [
        isA<ExpenseLoaded>()
            .having((s) => s.allExpenses.length, 'allExpenses length', 1)
            .having((s) => s.filteredExpenses.length, 'filteredExpenses length', 1),
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
        await pumpEventQueue();
        cubit.updateCategoryFilter('Food');
      },
      skip: 1,
      expect: () => [
        isA<ExpenseLoaded>()
            .having((s) => s.filteredExpenses.length, 'filteredExpenses length', 1)
            .having((s) => s.selectedCategory, 'selectedCategory', 'Food'),
      ],
    );
  });
}