import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _currentUserId;

  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  void setUserId(String userId) {
    _currentUserId = userId;
    refreshUnreadCount();
  }

  Future<void> refreshUnreadCount() async {
    if (_currentUserId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final notifications = await _notificationService.getUnreadNotifications(
        _currentUserId!,
      );
      _unreadCount = notifications.length;
    } catch (e) {
      print('Erreur lors du chargement des notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetCount() {
    _unreadCount = 0;
    notifyListeners();
  }

  // Incrémenter le compteur quand une nouvelle notification arrive
  void incrementCount() {
    _unreadCount++;
    notifyListeners();
  }

  // Décrémenter le compteur quand une notification est lue
  void decrementCount() {
    if (_unreadCount > 0) {
      _unreadCount--;
      notifyListeners();
    }
  }
}
