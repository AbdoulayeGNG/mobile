import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import 'notification_badge.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? additionalActions;
  final bool showNotificationIcon;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.additionalActions,
    this.showNotificationIcon = true,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final notificationProvider = context.watch<NotificationProvider>();

    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notificationProvider.setUserId(user.id);
      });
    }

    return AppBar(
      title: Text(title),
      centerTitle: true,
      elevation: 0,
      actions: [
        if (showNotificationIcon && user != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: NotificationBadge(
              userId: user.id,
              child: IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
                tooltip: 'Notifications',
              ),
            ),
          ),
        if (additionalActions != null) ...additionalActions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
