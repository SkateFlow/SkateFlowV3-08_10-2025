import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class UsuarioService {
  static const String baseUrl = 'http://SEU_IP:PORTA/usuario';

  static Future<List<Usuario>> fetchUsuarios() async {
    final response = await http.get(Uri.parse('$baseUrl/listar'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      List<Usuario> usuarios = jsonList.map((json) => Usuario.fromJson(json)).toList();
      return usuarios;
    } else {
      throw Exception('Falha ao carregar usuários');
    }
  }
}