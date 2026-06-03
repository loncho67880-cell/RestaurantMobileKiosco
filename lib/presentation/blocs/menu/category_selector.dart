import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurantmobile/presentation/blocs/menu/menu_bloc.dart';
import 'package:restaurantmobile/presentation/blocs/menu/menu_event.dart';
import 'package:restaurantmobile/presentation/blocs/menu/menu_state.dart';

class CategorySelector extends StatelessWidget {
  final MenuLoaded state;
  const CategorySelector({
    super.key, 
    required this.state,
  });

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
                  color: isSelected
                      ? theme.colorScheme.onSecondary
                      : theme.colorScheme.onSurface,
                ),
              ),
              selected: isSelected,
              selectedColor: theme.colorScheme.secondary,
              backgroundColor: theme.colorScheme.surface,
              onSelected: (bool selected) {
                if (selected) {
                  context.read<MenuBloc>().add(
                    SelectCategoryEvent(category.id),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}