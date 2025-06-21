import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/navigation_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class NotificationsScreen extends StatefulWidget {
  static const String routeName = '/notifications';

  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final notifications = await _notificationService.getAllNotifications(user.id);
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      await _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(
                  child: Text('Aucune notification'),
                )
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final isUnread = notification['read'] == 0;
                    return Dismissible(
                      key: Key(notification['id'].toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) async {
                        // TODO: Implémenter la suppression
                      },
                      child: ListTile(
                        leading: Icon(
                          _getNotificationIcon(notification['type'] as String),
                          color: isUnread
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                        title: Text(
                          notification['title'] as String,
                          style: TextStyle(
                            fontWeight:
                                isUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notification['description'] as String),
                            Text(
                              _formatDate(notification['created_at'] as String),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),                        onTap: () async {
                          if (isUnread) {
                            await _markAsRead(notification['id'].toString());
                          }
                          
                          if (context.mounted) {
                            await NavigationService().navigateToContent(
                              context,
                              contentId: notification['content_id'] as String,
                              type: notification['type'] as String,
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'course':
        return Icons.school;
      case 'quiz':
        return Icons.quiz;
      case 'forum':
        return Icons.forum;
      case 'achievement':
        return Icons.emoji_events;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
}
