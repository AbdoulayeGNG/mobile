import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class TeacherHomeScreen extends StatelessWidget {
  final User user;

  const TeacherHomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenue Prof. ${user.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              // TODO: Implement logout
            },
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16.0),
        crossAxisCount: 2,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: [
          _buildMenuCard(context, 'Gérer les Cours', Icons.edit, () {
            // TODO: Navigate to course management
          }),
          _buildMenuCard(context, 'Mes Classes', Icons.group, () {
            // TODO: Navigate to classes
          }),
          _buildMenuCard(context, 'Messages', Icons.message, () {
            // TODO: Navigate to messages
          }),
          _buildMenuCard(context, 'Statistiques', Icons.bar_chart, () {
            // TODO: Navigate to statistics
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add course screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4.0,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.0, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
