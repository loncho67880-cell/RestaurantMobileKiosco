import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../infrastructure/repositories/menu_repository.dart';
import 'menu_event.dart';
import 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuRepository menuRepository;

  MenuBloc({required this.menuRepository}) : super(MenuLoading()) {
    on<LoadMenuEvent>(_onLoadMenu);
    on<SelectCategoryEvent>(_onSelectCategory);
  }

  Future<void> _onLoadMenu(LoadMenuEvent event, Emitter<MenuState> emit) async {
    emit(MenuLoading());
    try {
      // Usamos el método que filtra por idioma pasando el localeCode del evento
      final categories = await menuRepository.loadCategories(event.localeCode ?? 'es');

      if (categories.isNotEmpty) {
        emit(
          MenuLoaded(
            categories: categories,
            selectedCategoryId: categories.first.id, // Por defecto la primera
          ),
        );
      } else {
        emit(const MenuError("No se encontraron categorías disponibles."));
      }
    } catch (e) {
      emit(MenuError("Error cargando el menú: ${e.toString()}"));
    }
  }

  void _onSelectCategory(SelectCategoryEvent event, Emitter<MenuState> emit) {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      emit(currentState.copyWith(selectedCategoryId: event.categoryId));
    }
  }
}
