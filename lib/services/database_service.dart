import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const String _userImageKey = 'user_profile_image';
  static const String _userNameKey = 'user_profile_name';

  // Salva a imagem do usuário no armazenamento local
  Future<String?> saveUserImage(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImagePath = '${appDir.path}/$fileName';
      
      // Copia a imagem para o diretório do app
      final File originalFile = File(imagePath);
      final File savedFile = await originalFile.copy(savedImagePath);
      
      // Salva o caminho no SharedPreferences
      await prefs.setString(_userImageKey, savedFile.path);
      
      return savedFile.path;
    } catch (e) {
      return null;
    }
  }

  // Recupera o caminho da imagem do usuário
  Future<String?> getUserImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString(_userImageKey);
      
      // Verifica se o arquivo ainda existe
      if (imagePath != null && await File(imagePath).exists()) {
        return imagePath;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Remove a imagem do usuário
  Future<bool> removeUserImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString(_userImageKey);
      
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      await prefs.remove(_userImageKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Salva o nome do usuário
  Future<bool> saveUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, name);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Recupera o nome do usuário
  Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    } catch (e) {
      return null;
    }
  }
}