import 'package:equatable/equatable.dart';
import 'package:restaurantmobile/domain/models/addition.dart';
import 'package:restaurantmobile/domain/models/dish.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddDishEvent extends CartEvent {
  final Dish dish;
  final List<Addition> additions;

  const AddDishEvent({
    required this.dish,
    required this.additions,
  });

  @override
  List<Object?> get props => [dish, additions];
}

class RemoveDishEvent extends CartEvent {
  final dynamic dish;

  const RemoveDishEvent(this.dish);

  @override
  List<Object?> get props => [dish];
}

class UpdateItemQuantityEvent extends CartEvent {
  final int index;
  final int newQuantity;

  const UpdateItemQuantityEvent({
    required this.index,
    required this.newQuantity,
  });

  @override
  List<Object?> get props => [index, newQuantity];
}

class RemoveAdditionFromItemEvent extends CartEvent {
  final int itemIndex;
  final Addition addition;

  const RemoveAdditionFromItemEvent({
    required this.itemIndex,
    required this.addition,
  });

  @override
  List<Object?> get props => [itemIndex, addition];
}

class ClearCartEvent extends CartEvent {}