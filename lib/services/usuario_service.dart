import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class UsuarioService {
  static String get baseUrl {
    // Para emulador Android usa 10.0.2.2, para dispositivo físico ou iOS usa localhost
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/usuario';
    } else {
      return 'http://localhost:8080/usuario';
    }
  }

  // 🔹 Buscar todos os usuários
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

  // 🔹 Login de usuário
  static Future<Usuario?> login(String email, String senha) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      print('Tentando login para: $email');
      print('URL: $url');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      print('Status do login: ${response.statusCode}');
      print('Resposta do login: ${response.body}');

      if (response.statusCode == 200) {
        return Usuario.fromJson(jsonDecode(response.body));
      } else {
        print('Erro ao fazer login: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro de conexão no login: $e');
      return null;
    }
  }

  // 🔹 Cadastro de novo usuário
  static Future<bool> cadastrar(String nome, String email, String senha) async {
    try {
      final url = Uri.parse('$baseUrl/save');
      print('Tentando cadastrar: $nome - $email');
      print('URL: $url');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'senha': senha,
          'nivelAcesso': 'USER',
          'statusUsuario': 'ATIVO'
        }),
      );

      print('Status do cadastro: ${response.statusCode}');
      print('Resposta do cadastro: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Erro ao cadastrar: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro de conexão no cadastro: $e');
      return false;
    }
  }
}
