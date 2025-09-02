import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repo;
  LoginUseCase(this._repo);

  Future<bool> execute(String email, String password) {
    return _repo.login(email, password);
  }
}