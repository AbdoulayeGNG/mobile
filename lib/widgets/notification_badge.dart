import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationBadge extends StatefulWidget {
  final Widget child;
  final String userId;
  final Color? badgeColor;
  final Color? textColor;
  final double? size;

  const NotificationBadge({
    Key? key,
    required this.child,
    required this.userId,
    this.badgeColor,
    this.textColor,
    this.size,
  }) : super(key: key);

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final notifications = await _notificationService.getUnreadNotifications(
        widget.userId,
      );
      
      if (mounted) {
        setState(() {
          _unreadCount = notifications.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _unreadCount == 0) {
      return widget.child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned(
          right: -5,
          top: -5,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: widget.badgeColor ?? Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: BoxConstraints(
              minWidth: widget.size ?? 16,
              minHeight: widget.size ?? 16,
            ),
            child: Center(
              child: Text(
                _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                style: TextStyle(
                  color: widget.textColor ?? Colors.white,
                  fontSize: (widget.size ?? 16) * 0.6,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
