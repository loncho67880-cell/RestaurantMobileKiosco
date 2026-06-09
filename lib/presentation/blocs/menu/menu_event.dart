import 'package:equatable/equatable.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenuEvent extends MenuEvent {
  final String? localeCode;
  final String restaurantId;
  final String branchId;
  const LoadMenuEvent({
    this.localeCode,
    required this.restaurantId,
    required this.branchId,
  });

  @override
  List<Object?> get props => [localeCode, restaurantId, branchId];
}

class SelectCategoryEvent extends MenuEvent {
  final String categoryId;
  const SelectCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}