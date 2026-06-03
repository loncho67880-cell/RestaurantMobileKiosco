import 'package:equatable/equatable.dart';
import 'package:restaurantmobile/domain/models/addition.dart';

class Dish extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryId;
  final List<Addition> additions;

  const Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    required this.additions,
  });

  /// Factory para construir el plato desde el mapa de JSON
  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      // Usamos (json[...] as num).toDouble() para evitar errores si el backend manda enteros o flotantes
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      categoryId: json['categoryId'] as String,
      additions: (json['additions'] as List<dynamic>?)
              ?.map((e) => Addition.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Método para convertir el objeto de vuelta a JSON (útil para enviar al backend o guardar en local)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'additions': additions.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        imageUrl,
        categoryId,
        additions,
      ];
}