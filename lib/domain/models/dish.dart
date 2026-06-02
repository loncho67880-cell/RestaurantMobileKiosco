import 'package:equatable/equatable.dart';
import 'addition.dart';

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

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(), imageUrl: '', categoryId: '', additions: [],
    );
  }

  @override
  List<Object?> get props => [id, name, description, price, imageUrl, categoryId, additions];
}