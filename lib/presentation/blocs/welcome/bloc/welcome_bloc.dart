import 'package:flutter_bloc/flutter_bloc.dart';

// Eventos
abstract class WelcomeEvent {}
class WelcomeScreenTapped extends WelcomeEvent {}

// Estados
abstract class WelcomeState {}
class WelcomeInitial extends WelcomeState {}
class WelcomeNavigateToMenu extends WelcomeState {}

// BLoC
class WelcomeBloc extends Cubit<WelcomeState> {
  WelcomeBloc() : super(WelcomeInitial());

  void handleScreenTap() {
    emit(WelcomeNavigateToMenu());
  }
  
  void resetState() {
    emit(WelcomeInitial());
  }
}