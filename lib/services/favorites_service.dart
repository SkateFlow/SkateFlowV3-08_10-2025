import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'auth_service.dart';

class FavoritesService extends ChangeNotifier {
  static const int maxFavoriteParks = AppConstants.maxFavoriteParks;
  static FavoritesService? _instance;
  
  factory FavoritesService() {
    _instance ??= FavoritesService._internal();
    return _instance!;
  }
  
  FavoritesService._internal();
  
  final Set<String> _favoriteParkIds = {};
  final AuthService _authService = AuthService();
  
  int get favoritesCount => _favoriteParkIds.length;

  String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/usuario/favorito';
    } else {
      return 'http://localhost:8080/usuario/favorito';
    }
  }

  Future<void> carregarFavoritos() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final url = Uri.parse('$baseUrl/listar/${user.id}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final String favoritosStr = response.body.replaceAll('"', '');
        _favoriteParkIds.clear();
        if (favoritosStr.isNotEmpty) {
          final ids = favoritosStr.split(',');
          _favoriteParkIds.addAll(ids);
        }
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao carregar favoritos: $e');
    }
  }

  Future<bool> addToFavorites(String parkId) async {
    final user = _authService.currentUser;
    print('=== ADICIONAR FAVORITO ===');
    print('User: $user');
    print('User ID: ${user?.id}');
    print('Park ID: $parkId');
    print('Is Logged In: ${_authService.isLoggedIn}');
    print('Current User ID: ${_authService.currentUserId}');
    
    if (user == null || user.id == 0) {
      print('ERRO: Usuário não logado ou ID inválido');
      return false;
    }

    try {
      final url = Uri.parse('$baseUrl/adicionar');
      print('URL: $url');
      
      final body = {
        'usuarioId': user.id,
        'lugarId': int.parse(parkId),
      };
      print('Body: $body');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');
      
      if (response.statusCode == 200) {
        _favoriteParkIds.add(parkId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      print('ERRO ao adicionar favorito: $e');
      print('StackTrace: $stackTrace');
      return false;
    }
  }

  Future<bool> removeFromFavorites(String parkId) async {
    final user = _authService.currentUser;
    if (user == null || user.id == 0) {
      print('Usuário não logado');
      return false;
    }

    try {
      final url = Uri.parse('$baseUrl/remover');
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuarioId': user.id,
          'lugarId': int.parse(parkId),
        }),
      );

      print('Resposta remover favorito: ${response.statusCode}');
      if (response.statusCode == 200) {
        _favoriteParkIds.remove(parkId);
        notifyListeners();
        return true;
      }
      print('Erro: ${response.body}');
      return false;
    } catch (e) {
      print('Erro ao remover favorito: $e');
      return false;
    }
  }

  bool isFavorite(String parkId) {
    return _favoriteParkIds.contains(parkId);
  }
}