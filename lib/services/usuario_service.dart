import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class UsuarioService {
  static const String baseUrl = 'http://10.0.2.2:8080/usuario';

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
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      return Usuario.fromJson(jsonDecode(response.body));
    } else {
      print('Erro ao fazer login: ${response.body}');
      return null;
    }
  }

  // 🔹 Cadastro de novo usuário
  static Future<bool> cadastrar(String nome, String email, String senha) async {
    final url = Uri.parse('$baseUrl/save');
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

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Erro ao cadastrar: ${response.body}');
      return false;
    }
  }
}
