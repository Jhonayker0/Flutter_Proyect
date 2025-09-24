import 'package:flutter_application/auth/domain/models/user.dart';

import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;
  SignUpUseCase(this.repository);

  Future<User?> execute(String name, String email, String password) {
    return repository.signUp(name, email, password);
  }
}
