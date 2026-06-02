import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurantmobile/infrastructure/repositories/menu_repository.dart';
import 'package:restaurantmobile/presentation/blocs/menu/menu_bloc.dart';
import 'package:restaurantmobile/presentation/blocs/menu/menu_event.dart';
import 'package:restaurantmobile/presentation/blocs/menu/menu_state.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => MenuRepository(),
      child: BlocProvider(
        create: (context) => MenuBloc(
          menuRepository: context.read<MenuRepository>(),
        )..add(LoadMenuEvent()),
        child: const _MenuView(),
      ),
    );
  }
}

class _MenuView extends StatelessWidget {
  const _MenuView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Menú", 
          style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)
        ),
        backgroundColor: theme.colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          if (state is MenuLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MenuError) {
            return Center(child: Text(state.errorMessage));
          }
          if (state is MenuLoaded) {
            return Column(
              children: [
                // 1. Categorías Horizontales en la Parte Superior
                _CategorySelector(state: state),
                
                // 2. Grid de platos filtrados de la categoría activa
                Expanded(
                  child: _DishesGrid(state: state),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final MenuLoaded state;
  const _CategorySelector({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final category = state.categories[index];
          final isSelected = category.id == state.selectedCategoryId;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(
                category.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isSelected ? theme.colorScheme.onSecondary : theme.colorScheme.onSurface,
                ),
              ),
              selected: isSelected,
              selectedColor: theme.colorScheme.secondary,
              backgroundColor: theme.colorScheme.surface,
              onSelected: (bool selected) {
                if (selected) {
                  context.read<MenuBloc>().add(SelectCategoryEvent(category.id));
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class _DishesGrid extends StatelessWidget {
  final MenuLoaded state;
  const _DishesGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final activeCategory = state.selectedCategory;
    final theme = Theme.of(context);

    // Ajuste responsivo de columnas para pantallas de Kiosco táctil
    final orientation = MediaQuery.of(context).orientation;
    final int crossAxisCount = (orientation == Orientation.portrait) ? 2 : 3;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeCategory.dishes.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8, // Controla la relación de aspecto vertical de las tarjetas
      ),
      itemBuilder: (context, index) {
        final dish = activeCategory.dishes[index];

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: theme.colorScheme.surface,
          child: InkWell(
            onTap: () {
              // Aquí abriremos el BottomSheet de adicionales (Papas, Guacamole...)
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen del Plato
                Expanded(
                  flex: 5,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      dish.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          Icon(Icons.fastfood_rounded, size: 50, color: theme.colorScheme.primary),
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
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dish.description,
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
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