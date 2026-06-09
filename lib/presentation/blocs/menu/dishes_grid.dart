import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurantmobile/domain/models/addition.dart';
import 'package:restaurantmobile/domain/models/dish.dart';
import 'package:restaurantmobile/presentation/blocs/app_config/app_config_cubit.dart';
import 'package:restaurantmobile/presentation/blocs/cart/cart_bloc.dart';
import 'package:restaurantmobile/presentation/blocs/cart/cart_event.dart';
import 'package:restaurantmobile/presentation/blocs/menu/menu_state.dart';

class DishesGrid extends StatelessWidget {
  final MenuLoaded state;
  const DishesGrid({super.key, required this.state});

  void _showAdditionsBottomSheet(BuildContext outerContext, Dish dish) {
    final List<Addition> selectedAdditions = [];
    // Obtenemos el cubit aquí para usarlo dentro del modal
    final configCubit = outerContext.read<AppConfigCubit>();

    showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (localContext, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    configCubit.translate('enhance_dish'), // 👈 Traducido
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  if (dish.additions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          configCubit.translate('no_additions'),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  else
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
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          secondary: Text(
                            '+ \$${addition.price.toStringAsFixed(0)}',
                          ),
                          value: isSelected,
                          activeColor: Colors.deepOrange,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (bool? checked) {
                            setModalState(() {
                              checked == true
                                  ? selectedAdditions.add(addition)
                                  : selectedAdditions.remove(addition);
                            });
                          },
                        ),
                      );
                    }),

                  const SizedBox(height: 20),
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
                        Navigator.pop(modalContext);
                        outerContext.read<CartBloc>().add(
                          AddDishEvent(
                            dish: dish,
                            additions: selectedAdditions,
                          ),
                        );

                        ScaffoldMessenger.of(outerContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${configCubit.translate('added_snack')}${dish.name}", // 👈 Traducido
                            ),
                          ),
                        );
                      },
                      child: Text(
                        configCubit.translate('confirm_add'), // 👈 Traducido
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

    return // En tu archivo dishes_grid.dart
    GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio:
            0.75, // Ajusta este valor para controlar la altura de la card
      ),
      itemCount: activeCategory.dishes.length,
      itemBuilder: (context, index) {
        final dish = activeCategory.dishes[index];

        return Card(
          clipBehavior: Clip
              .antiAlias, // Recomendado para que la imagen no se salga de la esquina
          child: Column(
            children: [
              // La imagen ocupa el espacio dinámico disponible
              Expanded(
                child: Image.network(
                  dish.imageUrl,
                  fit: BoxFit.cover, // Para que la imagen cubra bien el espacio
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    // Aquí el Flexible soluciona el desbordamiento
                    Flexible(
                      child: Text(
                        '\$${dish.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow
                            .ellipsis, // Si el texto es muy largo, añade "..."
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
