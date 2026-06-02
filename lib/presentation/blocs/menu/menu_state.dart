import 'package:equatable/equatable.dart';
import '../../../domain/models/category_menu.dart';

abstract class MenuState extends Equatable {
  const MenuState();
  
  @override
  List<Object?> get props => [];
}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<CategoryMenu> categories;
  final String selectedCategoryId;

  const MenuLoaded({
    required this.categories,
    required this.selectedCategoryId,
  });

  // Helper para obtener fácilmente los platos de la categoría activa
  CategoryMenu get selectedCategory => 
      categories.firstWhere((cat) => cat.id == selectedCategoryId);

  MenuLoaded copyWith({
    List<CategoryMenu>? categories,
    String? selectedCategoryId,
  }) {
    return MenuLoaded(
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }

  @override
  List<Object?> get props => [categories, selectedCategoryId];
}

class MenuError extends MenuState {
  final String errorMessage;
  const MenuError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}