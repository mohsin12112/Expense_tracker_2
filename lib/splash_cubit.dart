import 'package:flutter_bloc/flutter_bloc.dart';

// States
sealed class SplashState {}
class SplashInitial extends SplashState {}
class SplashCompleted extends SplashState {}

// Cubit
class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  /// Simulates initial app initialization / auth check before navigation
  void initializeApp() async {
    await Future.delayed(const Duration(seconds: 3));
    emit(SplashCompleted());
  }
}