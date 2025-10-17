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
      List<Usuario> usuarios =
          jsonList.map((json) => Usuario.fromJson(json)).toList();
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

      return response.statusCode == 200;
    } catch (e) {
      print('Erro de conexão no cadastro: $e');
      return false;
    }
  }

  // 🔹 Atualizar dados do usuário
  static Future<bool> atualizarUsuario(int id, String nome,
      {String? imagemBase64}) async {
    try {
      final url = Uri.parse('$baseUrl/atualizar/$id');
      print('Tentando atualizar usuário ID: $id');

      var request = http.MultipartRequest('PUT', url);
      request.fields['nome'] = nome;

      if (imagemBase64 != null) {
        imagemBase64 =
            imagemBase64.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
        final bytes = base64Decode(imagemBase64);
        request.files.add(http.MultipartFile.fromBytes(
          'foto',
          bytes,
          filename: 'profile.jpg',
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Status da atualização: ${response.statusCode}');
      print('Resposta: $responseBody');

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
      return false;
    }
  }

  // 🔹 Salvar foto via Base64
  static Future<bool> salvarFoto(int id, String fotoBase64) async {
    try {
      final url = Uri.parse('$baseUrl/foto/$id');
      print('Salvando foto para usuário ID: $id');
      print(
          'Tamanho da foto Base64 (antes da limpeza): ${fotoBase64.length} caracteres');

      fotoBase64 =
          fotoBase64.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');

      print(
          'Tamanho da foto Base64 (após limpeza): ${fotoBase64.length} caracteres');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'text/plain'},
        body: fotoBase64,
      );

      print('Status salvar foto: ${response.statusCode}');
      print('Resposta: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao salvar foto: $e');
      return false;
    }
  }

  // 🔹 Alterar senha do usuário
  static Future<bool> alterarSenha(
      int id, String senhaAtual, String novaSenha) async {
    try {
      final url = Uri.parse('$baseUrl/alterarSenha/$id');
      print('Alterando senha para usuário ID: $id');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'senhaAtual': senhaAtual, 'novaSenha': novaSenha}),
      );

      print('Status alterar senha: ${response.statusCode}');
      print('Resposta: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao alterar senha: $e');
      return false;
    }
  }

  // 🔹 Esqueceu a senha - enviar código
  static Future<bool> esqueceuSenha(String email) async {
    try {
      final url = Uri.parse('$baseUrl/esqueceuSenha');
      print('Enviando código para: $email');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print('Status esqueceu senha: ${response.statusCode}');
      print('Resposta: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao enviar código: $e');
      return false;
    }
  }

  // 🔹 Validar código de recuperação
  static Future<bool> validarCodigo(String email, String codigo) async {
    try {
      final url = Uri.parse('$baseUrl/validarCodigo');
      print('Validando código para: $email');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'codigo': codigo}),
      );

      print('Status validar código: ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao validar código: $e');
      return false;
    }
  }

  // 🔹 Redefinir senha com código
  static Future<bool> redefinirSenha(
      String email, String codigo, String novaSenha) async {
    try {
      final url = Uri.parse('$baseUrl/redefinirSenha');
      print('Redefinindo senha para: $email');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body:
            jsonEncode({'email': email, 'codigo': codigo, 'novaSenha': novaSenha}),
      );

      print('Status redefinir senha: ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao redefinir senha: $e');
      return false;
    }
  }

  // 🔹 Excluir conta com validação de senha (CORRIGIDO)
  static Future<bool> excluirConta(int id, String senha) async {
    try {
      final url = Uri.parse('$baseUrl/excluirConta/$id');
      print('Excluindo conta do usuário ID: $id');
      print('Senha enviada (protegida): ${'*' * senha.length}');

      // 🔧 Usando Request para enviar body em DELETE
      final request = http.Request('DELETE', url)
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode({'senha': senha});

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Status excluir conta: ${response.statusCode}');
      print('Resposta excluir conta: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao excluir conta: $e');
      return false;
    }
  }
}
