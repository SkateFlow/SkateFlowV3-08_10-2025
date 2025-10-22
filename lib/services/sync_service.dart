import 'dart:async';
import 'dart:convert';
import 'skatepark_service.dart';
import 'favorites_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  Timer? _syncTimer;
  final SkateparkService _skateparkService = SkateparkService();
  final FavoritesService _favoritesService = FavoritesService();
  
  static const Duration _syncInterval = Duration(seconds: 10);
  
  String? _lastSkateparksHash;
  String? _lastFavoritesHash;

  void startSync() {
    if (_syncTimer != null && _syncTimer!.isActive) return;
    
    _syncTimer = Timer.periodic(_syncInterval, (_) async {
      await _syncData();
    });
  }

  void stopSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  String _generateHash(dynamic data) {
    final jsonString = jsonEncode(data);
    return jsonString.hashCode.toString();
  }

  Future<void> _syncData() async {
    try {
      final skateparksData = await _skateparkService.fetchDataForComparison();
      final favoritesData = await _favoritesService.getFavoritesForComparison();
      
      final skateparksHash = _generateHash(skateparksData);
      final favoritesHash = _generateHash(favoritesData);
      
      bool hasChanges = false;
      
      if (_lastSkateparksHash != skateparksHash) {
        await _skateparkService.updateFromData(skateparksData);
        _lastSkateparksHash = skateparksHash;
        hasChanges = true;
      }
      
      if (_lastFavoritesHash != favoritesHash) {
        await _favoritesService.updateFromData(favoritesData);
        _lastFavoritesHash = favoritesHash;
        hasChanges = true;
      }
      
      if (hasChanges) {
        print('Sincronização: Dados atualizados');
      }
    } catch (e) {
      print('Erro na sincronização: $e');
    }
  }

  Future<void> forceSyncNow() async {
    _lastSkateparksHash = null;
    _lastFavoritesHash = null;
    await _syncData();
  }
}
