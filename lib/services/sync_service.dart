import 'dart:async';
import 'skatepark_service.dart';
import 'favorites_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  Timer? _syncTimer;
  final SkateparkService _skateparkService = SkateparkService();
  final FavoritesService _favoritesService = FavoritesService();
  
  static const Duration _syncInterval = Duration(seconds: 30);

  void startSync() {
    if (_syncTimer != null && _syncTimer!.isActive) return;
    
    _syncTimer = Timer.periodic(_syncInterval, (_) async {
      await _syncData();
    });
    
    _syncData();
  }

  void stopSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  Future<void> _syncData() async {
    try {
      await _skateparkService.fetchFromServer();
      await _favoritesService.carregarFavoritos();
    } catch (e) {
      print('Erro na sincronização: $e');
    }
  }

  Future<void> forceSyncNow() async {
    await _syncData();
  }
}
