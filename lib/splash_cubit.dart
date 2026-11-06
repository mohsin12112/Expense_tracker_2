import 'package:flutter_bloc/flutter_bloc.dart';

sealed class SplashState {}
class SplashInitial extends SplashState {}
class SplashCompleted extends SplashState {}

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  void initializeApp() async {
    await Future.delayed(const Duration(seconds: 3));
    emit(SplashCompleted());
  }
}