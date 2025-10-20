import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class LugarService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/lugar';
    } else {
      return 'http://localhost:8080/lugar';
    }
  }

  // Solicitar nova pista (vai para aprovação)
  static Future<bool> solicitarPista({
    required String nome,
    required String descricao,
    required String tipo,
    required String cep,
    required String rua,
    required String bairro,
    required String numero,
    required String latitude,
    required String longitude,
    required int categoriaId,
    required int usuarioId,
    String? foto1Base64,
    String? foto2Base64,
    String? foto3Base64,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/solicitar');
      
      final body = {
        'nome': nome,
        'descricao': descricao,
        'tipo': tipo,
        'cep': cep,
        'rua': rua,
        'bairro': bairro,
        'numero': numero,
        'latitude': latitude,
        'longitude': longitude,
        'categoriaId': categoriaId,
        'usuarioId': usuarioId,
        'valor': 0.0,
        'statusPista': 'pendente',
      };

      if (foto1Base64 != null && foto1Base64.isNotEmpty) {
        body['foto1'] = foto1Base64.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
      }
      if (foto2Base64 != null && foto2Base64.isNotEmpty) {
        body['foto2'] = foto2Base64.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
      }
      if (foto3Base64 != null && foto3Base64.isNotEmpty) {
        body['foto3'] = foto3Base64.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
      }

      print('Enviando solicitação de pista para backend: $nome');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao solicitar pista: $e');
      return false;
    }
  }

  // Criar nova pista diretamente (apenas para admin)
  static Future<bool> criarPista({
    required String nome,
    required String descricao,
    required String tipo,
    required String cep,
    required String rua,
    required String bairro,
    required String numero,
    required String latitude,
    required String longitude,
    required int categoriaId,
    required int usuarioId,
    String? foto1Base64,
    String? foto2Base64,
    String? foto3Base64,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/save');
      
      final body = {
        'nome': nome,
        'descricao': descricao,
        'tipo': tipo,
        'cep': cep,
        'rua': rua,
        'bairro': bairro,
        'numero': numero,
        'latitude': latitude,
        'longitude': longitude,
        'categoriaId': categoriaId,
        'usuarioId': usuarioId,
        'valor': 0.0,
      };

      if (foto1Base64 != null && foto1Base64.isNotEmpty) {
        body['foto1'] = foto1Base64.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
      }
      if (foto2Base64 != null && foto2Base64.isNotEmpty) {
        body['foto2'] = foto2Base64.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
      }
      if (foto3Base64 != null && foto3Base64.isNotEmpty) {
        body['foto3'] = foto3Base64.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
      }

      print('Criando pista diretamente no backend: $nome');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao criar pista: $e');
      return false;
    }
  }

  // Buscar todas as pistas
  static Future<List<Map<String, dynamic>>> buscarPistas() async {
    try {
      final url = Uri.parse('$baseUrl/listar');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        // Buscar fotos em Base64 para cada lugar
        for (var lugar in data) {
          final id = lugar['id'];
          
          // Buscar foto1
          try {
            final foto1Url = Uri.parse('$baseUrl/foto1/$id');
            final foto1Response = await http.get(foto1Url);
            if (foto1Response.statusCode == 200 && foto1Response.body.isNotEmpty) {
              lugar['foto1'] = foto1Response.body;
            }
          } catch (e) {
            print('Erro ao buscar foto1: $e');
          }
          
          // Buscar foto2
          try {
            final foto2Url = Uri.parse('$baseUrl/foto2/$id');
            final foto2Response = await http.get(foto2Url);
            if (foto2Response.statusCode == 200 && foto2Response.body.isNotEmpty) {
              lugar['foto2'] = foto2Response.body;
            }
          } catch (e) {
            print('Erro ao buscar foto2: $e');
          }
          
          // Buscar foto3
          try {
            final foto3Url = Uri.parse('$baseUrl/foto3/$id');
            final foto3Response = await http.get(foto3Url);
            if (foto3Response.statusCode == 200 && foto3Response.body.isNotEmpty) {
              lugar['foto3'] = foto3Response.body;
            }
          } catch (e) {
            print('Erro ao buscar foto3: $e');
          }
        }
        
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar pistas: $e');
      return [];
    }
  }
  
  // Buscar rating médio de uma pista
  static Future<double> buscarRatingMedio(int lugarId) async {
    try {
      final avaliacaoUrl = Platform.isAndroid 
          ? 'http://10.0.2.2:8080/avaliacao' 
          : 'http://localhost:8080/avaliacao';
      final url = Uri.parse('$avaliacaoUrl/media/$lugarId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return double.tryParse(response.body) ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      print('Erro ao buscar rating médio: $e');
      return 0.0;
    }
  }
}
