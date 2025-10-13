import '../models/pista_request.dart';

class PistaRequestService {
  static final PistaRequestService _instance = PistaRequestService._internal();
  factory PistaRequestService() => _instance;
  PistaRequestService._internal();

  final List<PistaRequest> _requests = [];
  final List<Function()> _listeners = [];

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

  List<PistaRequest> getAllRequests() {
    return List.from(_requests);
  }

  List<PistaRequest> getRequestsByStatus(String status) {
    return _requests.where((request) => request.status == status).toList();
  }

  Future<void> addRequest(PistaRequest request) async {
    // Simula chamada para API/BD
    await Future.delayed(const Duration(milliseconds: 500));
    
    _requests.add(request);
    _notifyListeners();
  }

  Future<void> updateRequestStatus(String id, String status) async {
    // Simula chamada para API/BD
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _requests.indexWhere((request) => request.id == id);
    if (index != -1) {
      final request = _requests[index];
      final updatedRequest = PistaRequest(
        id: request.id,
        nome: request.nome,
        descricao: request.descricao,
        categoria: request.categoria,
        cep: request.cep,
        rua: request.rua,
        bairro: request.bairro,
        numero: request.numero,
        latitude: request.latitude,
        longitude: request.longitude,
        publica: request.publica,
        fotos: request.fotos,
        status: status,
        dataSolicitacao: request.dataSolicitacao,
        usuarioId: request.usuarioId,
      );
      _requests[index] = updatedRequest;
      _notifyListeners();
    }
  }

  Future<void> deleteRequest(String id) async {
    // Simula chamada para API/BD
    await Future.delayed(const Duration(milliseconds: 500));
    
    _requests.removeWhere((request) => request.id == id);
    _notifyListeners();
  }
}