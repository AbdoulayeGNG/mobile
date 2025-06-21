import 'package:awesome_notifications/awesome_notifications.dart';
import '../services/database_service.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final DatabaseService _db = DatabaseService();

  // Initialiser les notifications
  Future<void> initialize() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Channel for basic notifications',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      ),
    ]);

    // Demander les permissions
    await AwesomeNotifications().isNotificationAllowed().then((
      isAllowed,
    ) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  // Créer une notification pour un nouveau contenu
  Future<void> createContentNotification({
    required String userId,
    required String contentId,
    required String title,
    required String description,
    required String type,
    DateTime? scheduledDate,
  }) async {
    int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    if (scheduledDate != null) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'basic_channel',
          title: title,
          body: description,
          payload: {'contentId': contentId, 'type': type},
        ),
        schedule: NotificationCalendar.fromDate(date: scheduledDate),
      );
    } else {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'basic_channel',
          title: title,
          body: description,
          payload: {'contentId': contentId, 'type': type},
        ),
      );
    }

    // Sauvegarder la notification dans la base de données
    final db = await _db.database;
    await db.insert('notifications', {
      'user_id': userId,
      'content_id': contentId,
      'title': title,
      'description': description,
      'type': type,
      'read': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Obtenir toutes les notifications d'un utilisateur
  Future<List<Map<String, dynamic>>> getAllNotifications(String userId) async {
    final db = await _db.database;
    return await db.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  // Obtenir les notifications non lues d'un utilisateur
  Future<List<Map<String, dynamic>>> getUnreadNotifications(
    String userId,
  ) async {
    final db = await _db.database;
    return await db.query(
      'notifications',
      where: 'user_id = ? AND read = 0',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  // Marquer une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    final db = await _db.database;
    await db.update(
      'notifications',
      {'read': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }
}
