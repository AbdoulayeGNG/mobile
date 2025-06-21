import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class AdminHomeScreen extends StatelessWidget {
  final User user;

  const AdminHomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
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
          _buildMenuCard(context, 'Utilisateurs', Icons.people, () {
            // TODO: Navigate to user management
          }),
          _buildMenuCard(context, 'Niveaux & Classes', Icons.school, () {
            // TODO: Navigate to levels and grades
          }),
          _buildMenuCard(context, 'Matières', Icons.subject, () {
            // TODO: Navigate to subjects
          }),
          _buildMenuCard(context, 'Rapports', Icons.analytics, () {
            // TODO: Navigate to reports
          }),
        ],
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
