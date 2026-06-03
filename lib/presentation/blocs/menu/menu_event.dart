import 'package:equatable/equatable.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenuEvent extends MenuEvent {
  final String? localeCode;
  const LoadMenuEvent({this.localeCode = 'es'});

  @override
  List<Object?> get props => [localeCode];
}

class SelectCategoryEvent extends MenuEvent {
  final String categoryId;
  const SelectCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}