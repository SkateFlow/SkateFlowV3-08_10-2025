import '../models/skatepark.dart';
import 'lugar_service.dart';

class SkateparkService {
  static final SkateparkService _instance = SkateparkService._internal();
  factory SkateparkService() => _instance;
  SkateparkService._internal();

  // Lista de pistas (carregadas do backend)
  final List<Skatepark> _skateparks = [];

  // Callbacks para notificar mudanças
  final List<Function()> _listeners = [];

  // Métodos para gerenciar listeners
  void addListener(Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  // Métodos para acessar dados
  List<Skatepark> getAllSkateparks() {
    return List.from(_skateparks);
  }

  Skatepark? getSkateparkById(String id) {
    try {
      return _skateparks.firstWhere((park) => park.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Skatepark> getSkateparksByType(String type) {
    if (type == 'Todos') return getAllSkateparks();
    return _skateparks.where((park) => park.type == type).toList();
  }

  List<Skatepark> getSkateparksByRating(double minRating) {
    if (minRating == 0.0) return getAllSkateparks();
    return _skateparks.where((park) => park.rating >= minRating).toList();
  }

  // Métodos para modificar dados (futuramente integrados com API/BD)
  Future<void> updateSkatepark(Skatepark updatedPark) async {
    // Simula chamada para API/BD
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _skateparks.indexWhere((park) => park.id == updatedPark.id);
    if (index != -1) {
      _skateparks[index] = updatedPark;
      _notifyListeners();
    }
  }

  Future<void> addSkatepark(Skatepark newPark) async {
    // Simula chamada para API/BD
    await Future.delayed(const Duration(milliseconds: 500));
    
    _skateparks.add(newPark);
    _notifyListeners();
  }

  Future<void> deleteSkatepark(String id) async {
    // Simula chamada para API/BD
    await Future.delayed(const Duration(milliseconds: 500));
    
    _skateparks.removeWhere((park) => park.id == id);
    _notifyListeners();
  }

  // Método para sincronizar com servidor (futuro)
  Future<void> syncWithServer() async {
    // Aqui será implementada a sincronização com o servidor
    // Por enquanto, apenas simula uma operação
    await Future.delayed(const Duration(seconds: 2));
  }

  // Buscar pistas do backend
  Future<void> fetchFromServer() async {
    try {
      final lugares = await LugarService.buscarPistas();
      
      // Limpar pistas antigas
      _skateparks.clear();
      
      // Converter lugares para skateparks
      for (final lugar in lugares) {
        // Apenas pistas ativadas
        if (lugar['statusPista'] != 'ativada') continue;
        
        // Buscar fotos do backend
        List<String> images = [];
        if (lugar['foto1'] != null) {
          images.add('data:image/jpeg;base64,${lugar['foto1']}');
        }
        if (lugar['foto2'] != null) {
          images.add('data:image/jpeg;base64,${lugar['foto2']}');
        }
        if (lugar['foto3'] != null) {
          images.add('data:image/jpeg;base64,${lugar['foto3']}');
        }

        
        // Buscar rating médio
        final rating = await LugarService.buscarRatingMedio(lugar['id']);
        
        final skatepark = Skatepark(
          id: lugar['id'].toString(),
          name: lugar['nome'] ?? 'Sem nome',
          type: lugar['categoria']?['nome'] ?? 'Street',
          lat: double.tryParse(lugar['latitude'] ?? '0') ?? 0.0,
          lng: double.tryParse(lugar['longitude'] ?? '0') ?? 0.0,
          rating: rating,
          address: '${lugar['rua'] ?? ''}, ${lugar['numero'] ?? ''} - ${lugar['bairro'] ?? ''}',
          features: [lugar['categoria']?['nome'] ?? 'Street'],
          description: lugar['descricao'] ?? 'Sem descrição',
          images: images,
          usuarioNome: lugar['usuario']?['nome'],
          usuarioNivelAcesso: lugar['usuario']?['nivelAcesso'],
        );
        
        _skateparks.add(skatepark);
      }
      
      _notifyListeners();
    } catch (e) {
      print('Erro ao buscar pistas do servidor: $e');
    }
  }
}