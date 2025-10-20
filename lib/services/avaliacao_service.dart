import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AvaliacaoService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/avaliacao';
    } else {
      return 'http://localhost:8080/avaliacao';
    }
  }

  // Salvar avaliação
  static Future<Map<String, dynamic>> salvarAvaliacao({
    required int lugarId,
    required int usuarioId,
    required int rating,
    required String comentario,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/save');
      
      final body = {
        'lugarId': lugarId,
        'usuarioId': usuarioId,
        'rating': rating,
        'comentario': comentario,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      print('Erro ao salvar avaliação: $e');
      return {'success': false, 'message': 'Erro ao conectar com servidor'};
    }
  }

  // Buscar avaliações de uma pista
  static Future<List<Map<String, dynamic>>> buscarAvaliacoes(int lugarId) async {
    try {
      final url = Uri.parse('$baseUrl/lugar/$lugarId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar avaliações: $e');
      return [];
    }
  }

  // Buscar média de avaliações
  static Future<double> buscarMediaAvaliacoes(int lugarId) async {
    try {
      final url = Uri.parse('$baseUrl/media/$lugarId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return double.tryParse(response.body) ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      print('Erro ao buscar média: $e');
      return 0.0;
    }
  }

  // Atualizar avaliação
  static Future<bool> atualizarAvaliacao({
    required int avaliacaoId,
    required int usuarioId,
    required int rating,
    required String comentario,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/update/$avaliacaoId');
      
      final body = {
        'usuarioId': usuarioId,
        'rating': rating,
        'comentario': comentario,
      };

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao atualizar avaliação: $e');
      return false;
    }
  }

  // Deletar avaliação
  static Future<bool> deletarAvaliacao({
    required int avaliacaoId,
    required int usuarioId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/delete/$avaliacaoId');
      
      final body = {
        'usuarioId': usuarioId,
      };

      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao deletar avaliação: $e');
      return false;
    }
  }
}
