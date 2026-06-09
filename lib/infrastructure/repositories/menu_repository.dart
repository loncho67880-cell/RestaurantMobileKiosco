import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../domain/models/category_menu.dart';

class MenuRepository {
  // Ajusta esta URL a tu configuración (recuerda que en emulador Android 'localhost' es '10.0.2.2')
  final String baseUrl = "https://ca96-2803-1800-1317-69fb-41b2-4960-4bd0-4f84.ngrok-free.app/api";

  Future<List<CategoryMenu>> loadCategories(
    String localeCode,
    String restaurantId,
    String branchId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/categories?lang=$localeCode&restaurantId=$restaurantId&branchId=$branchId',
    );

    try {
      final response = await http.get(
        url,
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        // Éxito: parsea el JSON
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => CategoryMenu.fromJson(e)).toList();
      } else {
        // Error de servidor (404, 500, etc.)
        throw Exception(
          'Error del servidor: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      // Error de red (No hay internet, servidor no encontrado, timeout)
      throw Exception(
        'Error de conexión: Verifica que tu IP sea correcta y el backend esté encendido. Detalle: ${e.message}',
      );
    } catch (e) {
      // Otro error
      throw Exception('Error inesperado: $e');
    }
  }
}
