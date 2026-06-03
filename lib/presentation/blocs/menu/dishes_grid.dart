import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurantmobile/domain/models/addition.dart';
import 'package:restaurantmobile/domain/models/dish.dart';
import 'package:restaurantmobile/presentation/blocs/cart/cart_bloc.dart';
import 'package:restaurantmobile/presentation/blocs/cart/cart_event.dart';
import 'package:restaurantmobile/presentation/blocs/menu/menu_state.dart';

class DishesGrid extends StatelessWidget {
  final MenuLoaded state;
  const DishesGrid({super.key, required this.state});

  // 🍔 1. Actualizamos esta función para que devuelva objetos con Nombre y Precio
  List<dynamic> _getAdditionsForCategory(String categoryName) {
    final nameLower = categoryName.toLowerCase();

    // Aquí puedes usar tu modelo 'Addition(name: ..., price: ...)' si ya lo tienes creado
    if (nameLower.contains('carne') || nameLower.contains('meat')) {
      return [
        {'name': 'Chimichurri', 'price': 2500},
        {'name': 'Guacamole', 'price': 4000},
        {'name': 'Papas fritas', 'price': 5500},
      ];
    } else if (nameLower.contains('postre') || nameLower.contains('dessert')) {
      return [
        {'name': 'Extra de Arequipe', 'price': 2000},
        {'name': 'Extra de Chocolate', 'price': 2000},
        {'name': 'Crema Batida', 'price': 1500},
      ];
    } else if (nameLower.contains('bebida') || nameLower.contains('drink')) {
      return [
        {'name': 'Hielo extra', 'price': 500},
        {'name': 'Limón', 'price': 800},
        {'name': 'Leche condensada', 'price': 2500},
      ];
    }
    return [
      {'name': 'Porción extra', 'price': 3000},
    ];
  }

void _showAdditionsBottomSheet(BuildContext outerContext, Dish dish) {
  final List<Addition> selectedAdditions = [];

  showModalBottomSheet(
    context: outerContext,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (modalContext) {
      // ⚠️ CRÍTICO: Asegúrate de que este 'return' exista aquí
      return StatefulBuilder(
        builder: (localContext, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Hace que se adapte al contenido
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Línea gris decorativa superior del modal
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  dish.name,
                  style: const TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Color explícito para evitar problemas de tema
                  ),
                ),
                const Text(
                  'Mejora tu plato con los mejores extras:',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Validación de seguridad: si el plato no tiene adiciones
                if (dish.additions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'Este plato no cuenta con adiciones disponibles.',
                        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    ),
                  )
                else
                  // Lista dinámica de adiciones usando spread operator (sin ListViews infinitos)
                  ...dish.additions.map((addition) {
                    final isSelected = selectedAdditions.contains(addition);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CheckboxListTile(
                        title: Text(
                          addition.name,
                          style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                        secondary: Text(
                          '+ \$${addition.price.toStringAsFixed(0)}',
                          style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
                        ),
                        value: isSelected,
                        activeColor: Colors.deepOrange,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? checked) {
                          // setModalState refresca únicamente el modal de forma reactiva
                          setModalState(() {
                            if (checked == true) {
                              selectedAdditions.add(addition);
                            } else {
                              selectedAdditions.remove(addition);
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),

                const SizedBox(height: 20),

                // Botón de Confirmación
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      // 1. Cerramos la vista del modal
                      Navigator.pop(modalContext);

                      // 2. Despachamos el evento con el contexto de la pantalla principal
                      outerContext.read<CartBloc>().add(AddDishEvent(
                            dish: dish,
                            additions: selectedAdditions,
                          ));

                      // 3. Notificación de éxito
                      ScaffoldMessenger.of(outerContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Agregado: ${dish.name} ${selectedAdditions.isEmpty ? 'sin adiciones' : 'con extras'}",
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Confirmar y Agregar',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

  // 📱 3. Tu GridView Principal intacto y funcional
  @override
  Widget build(BuildContext context) {
    final activeCategory = state.selectedCategory;
    final theme = Theme.of(context);

    final orientation = MediaQuery.of(context).orientation;
    final int crossAxisCount = (orientation == Orientation.portrait) ? 2 : 3;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeCategory.dishes.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final dish = activeCategory.dishes[index];

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: theme.colorScheme.surface,
          child: InkWell(
            onTap: () {
              // Llama correctamente a la función interna renovada
              _showAdditionsBottomSheet(context, dish);
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen del Plato
                Expanded(
                  flex: 10,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Builder(
                      builder: (context) {
                        final formattedName = dish.name.trim().replaceAll(
                          ' ',
                          '_',
                        );
                        final finalAssetPath =
                            'assets/images/$formattedName.jpg';

                        return Image.asset(
                          finalAssetPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.fastfood_rounded,
                                size: 50,
                                color: theme.colorScheme.primary,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                // Detalles del Plato
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dish.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dish.description,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Text(
                          "\$${dish.price.toStringAsFixed(0)}",
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
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
