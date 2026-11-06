# Expense Tracker v2 

An offline-first expense tracking mobile application built with Flutter, reactive BLoC/Cubit state management, and automated GitHub Actions CI/CD pipelines.

# Key Features

- **Offline Persistence:** Fast local transaction storage using `SharedPreferences`.
- **Reactive State:** Powered by `flutter_bloc` / `cubit` architecture.
- **Analytics Charts:** Visual category breakdown using `expense_chart_widget.dart` and `expense_chart_helper.dart`.
- **Dynamic Themes:** Light & Dark mode support managed globally by `ThemeCubit`.
- **Transaction Export:** Export expense reports (`expense_export_service.dart`).

# Architecture & File Structure
lib/
 budget_card_widget.dart
 empty_expense_widget.dart
 expense_chart_helper.dart
 expense_chart_widget.dart
 expense_cubit.dart
 expense_export_service.dart
 expense_form.dart
 expense_model.dart
 expense_repository.dart
 home_screen.dart
 main.dart
 splash_cubit.dart
 splash_screen.dart
 theme_cubit.dart

# Testing

- **Widget Tests:** `home_screen_test.dart` and `widget_test.dart` for UI rendering.
- **Cubit Tests:** `expense_cubit_test.dart` and `splash_cubit_test.dart` for state logic.
- **Mocking:** `mock_expense_repository.dart` using `mocktail`.

 Run tests locally:
 ```bash
 flutter test

 CI/CD Pipeline (GitHub Actions)
 CI (ci.yml):
 Runs static code analysis (flutter analyze) and executes tests on push.

 CD (cd.yml):
 Automatically builds release APKs and archives artifacts.

 ### Steps to save:
 1. Click into the left editor panel[cite: 16].
 2. Select all (`Ctrl + A`) and paste the text above[cite: 16].
 3. Press `Ctrl + S` to save.
