import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurantmobile/infrastructure/repositories/menu_repository.dart';
import 'package:restaurantmobile/presentation/blocs/app_config/app_config_cubit.dart';
import 'package:restaurantmobile/presentation/blocs/menu/floating_cartbar.dart';
import 'package:restaurantmobile/presentation/blocs/menu/menu_bloc.dart';
import 'package:restaurantmobile/presentation/blocs/menu/menu_event.dart';
import 'package:restaurantmobile/presentation/blocs/menu/menu_state.dart';
import 'package:restaurantmobile/presentation/blocs/menu/category_selector.dart';
import 'package:restaurantmobile/presentation/blocs/menu/dishes_grid.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Leemos el idioma actual guardado en el estado global de la App
    final currentLocale = context.read<AppConfigCubit>().state.localeCode;

    return RepositoryProvider(
      create: (context) => MenuRepository(),
      child: BlocProvider(
        // 👈 Volvemos a un solo BlocProvider clásico
        create: (context) =>
            MenuBloc(menuRepository: context.read<MenuRepository>())..add(
              LoadMenuEvent(localeCode: currentLocale),
            ), // Tu fix del idioma se queda intacto 🚀
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
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.onPrimary,
          ),
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
                CategorySelector(state: state),

                // 2. Grid de platos filtrados de la categoría activa
                Expanded(child: DishesGrid(state: state)),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: const FloatingCartBar(),
    );
  }
}
