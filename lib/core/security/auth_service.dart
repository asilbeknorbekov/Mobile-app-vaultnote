class AuthService {
  bool _isAuthenticated = true;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> authenticate() async {
    _isAuthenticated = true;
    return true;
  }

  void lock() {
    _isAuthenticated = false;
  }
}
