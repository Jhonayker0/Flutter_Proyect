import 'package:flutter_application/domain/models/user.dart';

abstract class AuthRepository {
  Future<User?> login(String email, String password);
  Future<User?> signUp(String name, String email, String password);
}
