import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _db = DatabaseService();
  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<User?> login(String email, String password) async {
    try {
      final user = await _db.authenticateUser(email, password);
      if (user != null) {
        await _saveUserData(user.id, user);
        return user;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phoneNumber,
    String? levelId,
  }) async {
    try {
      // Vérifier si l'email existe déjà
      final existingUser = await _db.getUserByEmail(email);
      if (existingUser != null) {
        return false;
      }

      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        password: password, // Le mot de passe sera hashé par le DatabaseService
        name: fullName,
        role: role.value,
        phoneNumber: phoneNumber,
        profileImage: null,
        levelId: levelId, // Ajout du niveau pour les élèves
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db.createUser(newUser);
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<void> _saveUserData(String id, User user) async {
    await _initPrefs();
    await _prefs!.setString('userId', id);
    await _prefs!.setString('user', jsonEncode(user.toJson()));
    await _db.saveLastLoggedInUserId(id);
  }

  Future<User?> getCurrentUser() async {
    await _initPrefs();
    final userId = await _db.getLastLoggedInUserId();
    if (userId != null) {
      return await _db.getUserById(userId);
    }
    return null;
  }

  Future<void> logout() async {
    await _initPrefs();
    await _prefs!.clear();
    // Supprimer aussi l'ID de l'utilisateur dans la base de données
    await _db.saveLastLoggedInUserId('');
  }
}
