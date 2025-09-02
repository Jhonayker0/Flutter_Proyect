class AuthService {
  Future<void> signOut() async {
    // TODO: cerrar sesión real (token, firebase, etc.)
    await Future.delayed(const Duration(milliseconds: 200));
  }
}