import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurantmobile/domain/models/cartItem.dart';
import 'package:restaurantmobile/presentation/blocs/cart/cart_bloc.dart';
import 'package:restaurantmobile/presentation/blocs/app_config/app_config_cubit.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // 🌍 Diccionario local multiidioma mapeado para esta pantalla
  static const Map<String, Map<String, String>> _localizedStrings = {
    'es': {
      'orderSummary': 'Resumen del Pedido',
      'emptyCart': 'Tu carrito está vacío',
      'additionsTitle': 'Adiciones:',
      'totalLabel': 'Total General:',
      'processPaymentBtn': 'Procesar Pago',
    },
    'en': {
      'orderSummary': 'Order Summary',
      'emptyCart': 'Your cart is empty',
      'additionsTitle': 'Additions:',
      'totalLabel': 'Grand Total:',
      'processPaymentBtn': 'Process Payment',
    },
  };

  @override
  Widget build(BuildContext context) {
    // (Nota: Si tu propiedad en el estado se llama 'languageCode' o similar, ajusta 'localeCode')
    final configCubit = context.read<AppConfigCubit>();
    final String currentLang = configCubit.state.localeCode;

    // Filtramos los textos según el idioma activo del usuario
    final l10n = _localizedStrings[currentLang] ?? _localizedStrings['es']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n['orderSummary']!),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.pop(context), // Regresa al menú para seguir adicionando
        ),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return Center(
              child: Text(
                l10n['emptyCart']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return _CartItemTile(
                      item: item,
                      itemIndex: index,
                      l10n: l10n,
                    );
                  },
                ),
              ),
              _CartSummaryFooter(items: state.items, l10n: l10n),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final int itemIndex;
  final Map<String, String> l10n;

  const _CartItemTile({
    required this.item,
    required this.itemIndex,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.dish.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${item.dish.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Controles incrementales del carrito
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        context.read<CartBloc>().add(
                          UpdateItemQuantityEvent(
                            index: itemIndex,
                            newQuantity: item.quantity - 1,
                          ),
                        );
                      },
                    ),
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        context.read<CartBloc>().add(
                          UpdateItemQuantityEvent(
                            index: itemIndex,
                            newQuantity: item.quantity + 1,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            // Render de adiciones seleccionadas (Chips interactivos con eliminación)
            if (item.additions.isNotEmpty) ...[
              const Divider(height: 20),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  l10n['additionsTitle']!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: item.additions.map((addition) {
                  return Chip(
                    backgroundColor: Colors.grey[100],
                    side: BorderSide(color: Colors.grey[300]!),
                    label: Text(
                      '${addition.name} (+\$${addition.price.toStringAsFixed(0)})',
                    ),
                    deleteIcon: const Icon(
                      Icons.cancel,
                      size: 18,
                      color: Colors.grey,
                    ),
                    onDeleted: () {
                      context.read<CartBloc>().add(
                        RemoveAdditionFromItemEvent(
                          itemIndex: itemIndex,
                          addition: addition,
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CartSummaryFooter extends StatelessWidget {
  final List<CartItem> items;
  final Map<String, String> l10n;

  const _CartSummaryFooter({required this.items, required this.l10n});

  @override
  Widget build(BuildContext context) {
    // Envolvemos solo el footer en un BlocBuilder para ser reactivos
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        // Usamos directamente el total del estado que ya calcula el bloc
        final total = state.totalAmount; 

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n['totalLabel']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('\$${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: total > 0 ? () { // Bloqueamos si el total es 0
                      Navigator.of(context).pushNamed('/dataphone_payment', arguments: total);
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(l10n['processPaymentBtn']!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
