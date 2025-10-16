import 'dart:convert';
import 'dart:io';
import 'database_service.dart';
import 'usuario_service.dart';
import '../models/usuario.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isLoggedIn = false;
  String? _currentUserId;
  String? _currentUserName;
  String? _currentUserImage;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;
  String? get currentUserImage => _currentUserImage;

  // Callbacks para notificar mudanças
  final List<Function()> _listeners = [];

  void addListener(Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    // Debounce para evitar notificações excessivas
    Future.microtask(() {
      for (final listener in _listeners) {
        try {
          listener();
        } catch (e) {
          // Ignora erros de listeners inválidos
        }
      }
    });
  }

  // Login real com backend
  Future<bool> login(String email, String password) async {
    try {
      final Usuario? usuario = await UsuarioService.login(email, password);
      
      if (usuario != null) {
        _isLoggedIn = true;
        _currentUserId = usuario.id.toString();
        _currentUserName = usuario.nome;
        _currentUserImage = null; // Backend não tem imagem ainda
        
        // Salva dados localmente para cache
        final DatabaseService databaseService = DatabaseService();
        await databaseService.saveUserName(usuario.nome);
        
        _notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // Simula logout
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    _isLoggedIn = false;
    _currentUserId = null;
    _currentUserName = null;
    _notifyListeners();
  }

  // Registro real com backend
  Future<bool> register(String email, String password, String username) async {
    try {
      final bool success = await UsuarioService.cadastrar(username, email, password);
      
      if (success) {
        // Após cadastro, faz login automaticamente
        return await login(email, password);
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // Verifica se o usuário está logado (para uso em widgets)
  bool checkAuthStatus() {
    return _isLoggedIn;
  }

  // Simula um usuário logado para teste
  Future<void> simulateLoggedUser() async {
    _isLoggedIn = true;
    _currentUserId = 'user_demo';
    
    // Carrega dados salvos do banco
    final DatabaseService databaseService = DatabaseService();
    _currentUserName = await databaseService.getUserName() ?? 'Usuário Demo';
    _currentUserImage = await databaseService.getUserImage();
    
    _notifyListeners();
  }

  // Atualiza o nome do usuário
  Future<bool> updateUserName(String newName) async {
    if (newName.isNotEmpty && _currentUserId != null) {
      try {
        final int userId = int.parse(_currentUserId!);
        final success = await UsuarioService.atualizarUsuario(userId, newName);
        
        if (success) {
          _currentUserName = newName;
          // Salva localmente para cache
          final DatabaseService databaseService = DatabaseService();
          await databaseService.saveUserName(newName);
          _notifyListeners();
          return true;
        }
      } catch (e) {
        print('Erro ao atualizar nome: $e');
      }
    }
    return false;
  }

  // Atualiza a imagem do usuário
  Future<bool> updateUserImage(String? imagePath) async {
    if (_currentUserId != null) {
      try {
        final DatabaseService databaseService = DatabaseService();
        
        if (imagePath != null) {
          // Converte imagem para base64
          final File imageFile = File(imagePath);
          final List<int> imageBytes = await imageFile.readAsBytes();
          final String base64Image = base64Encode(imageBytes);
          
          // Envia para backend
          final int userId = int.parse(_currentUserId!);
          final success = await UsuarioService.atualizarUsuario(
            userId, 
            _currentUserName ?? '', 
            imagemBase64: base64Image
          );
          
          if (success) {
            // Salva localmente para cache
            final savedPath = await databaseService.saveUserImage(imagePath);
            _currentUserImage = savedPath;
          } else {
            // Se falhou no backend, ainda salva localmente
            final savedPath = await databaseService.saveUserImage(imagePath);
            _currentUserImage = savedPath;
          }
        } else {
          // Remove imagem
          final int userId = int.parse(_currentUserId!);
          await UsuarioService.atualizarUsuario(userId, _currentUserName ?? '');
          await databaseService.removeUserImage();
          _currentUserImage = null;
        }
        
        _notifyListeners();
        return true;
      } catch (e) {
        print('Erro ao atualizar imagem: $e');
      }
    }
    return false;
  }
}