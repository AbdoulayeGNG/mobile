import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  User? _currentUser;
  bool _isLoading = false;

  AuthProvider() {
    _loadLastLoggedInUser();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  Future<void> _loadLastLoggedInUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = await _db.getLastLoggedInUserId();
      if (userId != null) {
        _currentUser = await _db.getUserById(userId);
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'utilisateur: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserPreference(String userId) async {
    try {
      await _db.saveLastLoggedInUserId(userId);
    } catch (e) {
      print('Erreur lors de la sauvegarde des préférences: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _db.authenticateUser(email, password);
      if (user != null) {
        _currentUser = user;
        await _saveUserPreference(user.id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur de connexion: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phoneNumber,
    String? levelId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Vérifier si l'email existe déjà
      final existingUser = await _db.getUserByEmail(email);
      if (existingUser != null) {
        return false;
      }

      // Créer un nouvel utilisateur
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        password: password,
        name: name,
        role: role.value, // Conversion de UserRole en String
        phoneNumber: phoneNumber,
        profileImage: null,
        levelId: levelId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db.createUser(newUser);
      _currentUser = newUser;
      await _saveUserPreference(newUser.id);
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de la création de l\'utilisateur: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _db.saveLastLoggedInUserId(''); // Efface l'ID de l'utilisateur
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }
}
