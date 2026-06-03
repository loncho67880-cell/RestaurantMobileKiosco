import 'package:equatable/equatable.dart';
import 'package:restaurantmobile/domain/models/addition.dart';
import 'package:restaurantmobile/domain/models/dish.dart';

/// Representa un plato individual dentro del carrito junto con su cantidad
class CartItem extends Equatable {
  final Dish dish;
  final int quantity;
  final List<Addition> additions;

  const CartItem({
    required this.dish,
    required this.additions,
    this.quantity = 1,
  });

  double get totalPrice {
    double totalAdditions = additions.fold(0.0, (sum, addition) => sum + addition.price);
    return dish.price + totalAdditions;
  }

  CartItem copyWith({Dish? dish, int? quantity, List<Addition>? additions}) {
    return CartItem(
      dish: dish ?? this.dish,
      additions: additions ?? this.additions,
      quantity: quantity ?? this.quantity
    );
  }

  @override
  List<Object?> get props => [dish, quantity];
}

/// Estado global del Carrito de compras
class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  // Getters útiles para la UI
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  CartState copyWith({List<CartItem>? items}) {
    return CartState(
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [items];
}