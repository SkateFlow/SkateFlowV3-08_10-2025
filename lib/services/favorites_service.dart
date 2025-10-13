import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class FavoritesService extends ChangeNotifier {
  static const int maxFavoriteParks = AppConstants.maxFavoriteParks;
  static FavoritesService? _instance;
  
  factory FavoritesService() {
    _instance ??= FavoritesService._internal();
    return _instance!;
  }
  
  FavoritesService._internal();
  
  final List<Map<String, dynamic>> _favoriteParks = [];

  List<Map<String, dynamic>> get favoriteParks => List.unmodifiable(_favoriteParks);

  bool canAddToFavorites() {
    return _favoriteParks.length < maxFavoriteParks;
  }

  bool addToFavorites(Map<String, dynamic> park) {
    if (canAddToFavorites()) {
      // Garantir que o park tenha todas as informações necessárias
      final completePark = {
        'name': park['name'],
        'type': park['type'],
        'distance': park['distance'],
        'rating': park['rating'],
        'image': park['image'],
        'address': park['address'] ?? 'Endereço não disponível',
        'hours': park['hours'] ?? '6h às 22h',
      };
      _favoriteParks.add(completePark);
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeFromFavorites(String parkName) {
    _favoriteParks.removeWhere((park) => park['name'] == parkName);
    notifyListeners();
  }

  bool isFavorite(String parkName) {
    return _favoriteParks.any((park) => park['name'] == parkName);
  }
}