import 'package:flutter_application/auth/domain/models/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repo;
  LoginUseCase(this._repo);
  

  Future<User?> execute(String email, String password) {
    return _repo.login(email, password);
  }
}






