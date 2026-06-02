import 'package:equatable/equatable.dart';

class Addition extends Equatable {
  final String id;
  final String name;
  final double price;

  const Addition({
    required this.id,
    required this.name,
    required this.price,
  });

  factory Addition.fromJson(Map<String, dynamic> json) {
    return Addition(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, name, price];
}