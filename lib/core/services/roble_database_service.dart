import 'package:dio/dio.dart';
import 'package:flutter_application/core/config/roble_config.dart';
import 'package:flutter_application/core/services/roble_http_service.dart';

class RobleDatabaseService {
  final RobleHttpService _httpService;

  RobleDatabaseService(this._httpService);

  /// Lee registros de una tabla específica
  Future<List<Map<String, dynamic>>> read(String tableName) async {
    try {
      final response = await _httpService.dio.get(
        RobleConfig.readEndpoint,
        queryParameters: {'tableName': tableName},
      );
      
      print('📖 Leyendo tabla $tableName: ${response.statusCode}');
      
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      
      return [];
    } on DioException catch (e) {
      print('❌ Error leyendo tabla $tableName: ${e.message}');
      throw Exception('Error al leer datos de $tableName: ${e.message}');
    }
  }

  /// Inserta nuevos registros en una tabla
  Future<void> insert(String tableName, List<Map<String, dynamic>> records) async {
    try {
      final response = await _httpService.dio.post(
        RobleConfig.insertEndpoint,
        data: {
          'tableName': tableName,
          'records': records,
        },
      );
      
      print('✅ Insertado en tabla $tableName: ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ Error insertando en tabla $tableName: ${e.message}');
      throw Exception('Error al insertar en $tableName: ${e.message}');
    }
  }

  /// Actualiza un registro específico
  Future<void> update(String tableName, String id, Map<String, dynamic> updates) async {
    try {
      final response = await _httpService.dio.put(
        RobleConfig.updateEndpoint,
        data: {
          'tableName': tableName,
          'idColumn': '_id',
          'idValue': id,
          'updates': updates,
        },
      );
      
      print('🔄 Actualizado en tabla $tableName (ID: $id): ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ Error actualizando tabla $tableName: ${e.message}');
      throw Exception('Error al actualizar $tableName: ${e.message}');
    }
  }

  /// Elimina un registro específico
  Future<void> delete(String tableName, String id) async {
    try {
      final response = await _httpService.dio.delete(
        RobleConfig.deleteEndpoint,
        data: {
          'tableName': tableName,
          'idColumn': '_id',
          'idValue': id,
        },
      );
      
      print('🗑️ Eliminado de tabla $tableName (ID: $id): ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ Error eliminando de tabla $tableName: ${e.message}');
      throw Exception('Error al eliminar de $tableName: ${e.message}');
    }
  }
}