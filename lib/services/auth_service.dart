class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isLoggedIn = false;
  String? _currentUserId;
  String? _currentUserName;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;

  // Callbacks para notificar mudanças
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

  // Simula login
  Future<bool> login(String email, String password) async {
    // Simula chamada para API
    await Future.delayed(const Duration(seconds: 1));
    
    // Simula validação básica
    if (email.isNotEmpty && password.isNotEmpty) {
      _isLoggedIn = true;
      _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _currentUserName = email.split('@')[0];
      _notifyListeners();
      return true;
    }
    
    return false;
  }

  // Simula logout
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    _isLoggedIn = false;
    _currentUserId = null;
    _currentUserName = null;
    _notifyListeners();
  }

  // Simula registro
  Future<bool> register(String email, String password, String username) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty) {
      _isLoggedIn = true;
      _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _currentUserName = username;
      _notifyListeners();
      return true;
    }
    
    return false;
  }

  // Verifica se o usuário está logado (para uso em widgets)
  bool checkAuthStatus() {
    return _isLoggedIn;
  }
}