import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/models/category_menu.dart';

class MenuRepository {
  Future<List<CategoryMenu>> getMenuData() async {
    // Simulamos un pequeño delay de red para que el Shimmer/Loader del Kiosco se aprecie
    await Future.delayed(const Duration(milliseconds: 600));
    
    final String response = await rootBundle.loadString('assets/mockup/categories.json');
    final List<dynamic> data = json.decode(response);
    
    final categories = data.map((cat) => CategoryMenu.fromJson(cat)).toList();
    // Los ordenamos según la propiedad "order" definida en tu backend
    categories.sort((a, b) => a.order.compareTo(b.order));
    
    return categories;
  }
}