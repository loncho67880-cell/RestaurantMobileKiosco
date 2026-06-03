import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurantmobile/domain/models/addition.dart';
import 'package:restaurantmobile/domain/models/cartItem.dart';
import 'cart_event.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddDishEvent>(_onAddDish);
    on<RemoveDishEvent>(_onRemoveDish);
    on<ClearCartEvent>(_onClearCart);
    on<UpdateItemQuantityEvent>(_onUpdateItemQuantity);
    on<RemoveAdditionFromItemEvent>(_onRemoveAdditionFromItem);
  }

  void _onAddDish(AddDishEvent event, Emitter<CartState> emit) {
    final updatedItems = List<CartItem>.from(state.items);
    
    // Verificamos si el producto ya está en el carrito usando su ID
    final index = updatedItems.indexWhere((item) => item.dish.id == event.dish.id);

    if (index >= 0) {
      // Si ya existe, incrementamos la cantidad
      updatedItems[index] = updatedItems[index].copyWith(
        quantity: updatedItems[index].quantity + 1,
      );
    } else {
      // Si es nuevo, lo agregamos a la lista con cantidad inicial 1
      updatedItems.add(CartItem(
        dish: event.dish, 
        quantity: 1,
        additions: event.additions,
      ));
    }

    emit(state.copyWith(items: updatedItems));
  }

  void _onRemoveDish(RemoveDishEvent event, Emitter<CartState> emit) {
    final updatedItems = List<CartItem>.from(state.items);
    final index = updatedItems.indexWhere((item) => item.dish.id == event.dish.id);

    if (index >= 0) {
      if (updatedItems[index].quantity > 1) {
        // Si hay más de uno, disminuimos la cantidad en 1
        updatedItems[index] = updatedItems[index].copyWith(
          quantity: updatedItems[index].quantity - 1,
        );
      } else {
        // Si solo quedaba uno, lo removemos por completo del carrito
        updatedItems.removeAt(index);
      }
    }

    emit(state.copyWith(items: updatedItems));
  }

  // ===== ¡AQUÍ ESTABAN FALTANDO ESTOS DOS MÉTODOS! =====

  void _onUpdateItemQuantity(UpdateItemQuantityEvent event, Emitter<CartState> emit) {
    final updatedItems = List<CartItem>.from(state.items);
    
    // Validamos que el índice exista en la lista para evitar caídas (RangeError)
    if (event.index >= 0 && event.index < updatedItems.length) {
      if (event.newQuantity <= 0) {
        // Si la cantidad baja a 0, eliminamos el plato por completo
        updatedItems.removeAt(event.index);
      } else {
        // Si no, actualizamos la cantidad usando copyWith
        updatedItems[event.index] = updatedItems[event.index].copyWith(
          quantity: event.newQuantity,
        );
      }
      emit(state.copyWith(items: updatedItems));
    }
  }

  void _onRemoveAdditionFromItem(RemoveAdditionFromItemEvent event, Emitter<CartState> emit) {
    final updatedItems = List<CartItem>.from(state.items);
    
    if (event.itemIndex >= 0 && event.itemIndex < updatedItems.length) {
      final currentItem = updatedItems[event.itemIndex];
      
      // Filtramos la lista excluyendo la adición que el usuario quiere quitar
      // Nota: Si tu modelo Addition no tiene id, cámbialo por: (a) => a != event.addition
      final updatedAdditions = currentItem.additions
          .where((a) => a.id != event.addition.id)
          .toList();
      
      // Re-creamos el CartItem con la nueva lista de adiciones filtrada
      updatedItems[event.itemIndex] = CartItem(
        dish: currentItem.dish,
        quantity: currentItem.quantity,
        additions: updatedAdditions,
      );
      
      emit(state.copyWith(items: updatedItems));
    }
  }

  void _onClearCart(ClearCartEvent event, Emitter<CartState> emit) {
    emit(const CartState());
  }
}

// Nota: Dejar los eventos aquí al final funciona perfectamente gracias al import local, 
// solo asegúrate de que no estén duplicados dentro de tu archivo 'cart_event.dart'.
class UpdateItemQuantityEvent extends CartEvent {
  final int index;
  final int newQuantity;
  UpdateItemQuantityEvent({required this.index, required this.newQuantity});
}

class RemoveAdditionFromItemEvent extends CartEvent {
  final int itemIndex;
  final Addition addition;
  RemoveAdditionFromItemEvent({required this.itemIndex, required this.addition});
}