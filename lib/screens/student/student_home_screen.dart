import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class StudentHomeScreen extends StatelessWidget {
  final User user;

  const StudentHomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            const SizedBox(width: 8),
            const Text(
              'Bibliothèque',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(width: 80),
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                // Action notification
              },
              tooltip: 'Notifications',
            ),
            const SizedBox(width: 18),
            IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white),
              onPressed: () {
                // Action profil
              },
              tooltip: 'Profil',
            ),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              accountName: Text(user.name),
              accountEmail: Text(user.email),
            ),
            _drawerItem(Icons.home, 'Accueil', () {}),
            _drawerItem(Icons.library_books, 'Bibliothèque', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/bibliotheque');}),
            _drawerItem(Icons.forum, 'Forum', () {}),
            _drawerItem(Icons.trending_up, 'Progression', () {}),
            _drawerItem(Icons.settings, 'Paramètres', () {}),
            _drawerItem(Icons.notifications, 'Notifications', () {}),
            _drawerItem(Icons.account_circle, 'Profil', () {}),
            const Divider(),
            _drawerItem(Icons.exit_to_app, 'Déconnexion', () async {
              await context.read<AuthProvider>().logout();
            }),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salutation dynamique
            Text(
              'Bonjour, ${user.name} !',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Section raccourcis (4 cartes)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _ShortcutCard(
                  icon: Icons.library_books,
                  label: 'Bibliothèque',
                  color: Colors.blue.shade100,
                  onTap: () {
                    Navigator.pushNamed(context, '/bibliotheque');
                  },
                ),
                _ShortcutCard(
                  icon: Icons.trending_up,
                  label: 'Progression',
                  color: Colors.green.shade100,
                  onTap: () {},
                ),
                _ShortcutCard(
                  icon: Icons.edit,
                  label: 'Exercices',
                  color: Colors.orange.shade100,
                  onTap: () {Navigator.pushNamed(context, '/exercices');},
                ),
                _ShortcutCard(
                  icon: Icons.forum,
                  label: 'Forum',
                  color: Colors.purple.shade100,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Section ressources recommandées
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Ressources recommandées',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.star, color: Colors.amber),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 210, // Augmente la hauteur si besoin
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recommendedResources.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final res = recommendedResources[index];
                  return _ResourceCard(
                    title: res['title'],
                    description: res['description'],
                    icon:
                        res['type'] == 'PDF'
                            ? Icons.picture_as_pdf
                            : res['type'] == 'Vidéo'
                            ? Icons.play_circle_fill
                            : Icons.edit,
                    iconColor:
                        res['type'] == 'PDF'
                            ? Colors.red
                            : res['type'] == 'Vidéo'
                            ? Colors.blue
                            : Colors.orange,
                    actionLabel:
                        res['isDownloaded'] ? 'Consulter' : 'Télécharger',
                    onAction: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }
}

class _ShortcutCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShortcutCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.black54),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final String actionLabel;
  final VoidCallback onAction;

  const _ResourceCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(90, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Exemple de données à placer dans le fichier ou à remplacer par ta logique :
final List<Map<String, dynamic>> recommendedResources = [
  {
    'title': 'Fonctions du second degré',
    'description': 'Cours PDF complet avec exercices corrigés.',
    'type': 'PDF',
    'isDownloaded': false,
  },
  {
    'title': 'Les bases de la chimie',
    'description': 'Vidéo explicative pour débutants.',
    'type': 'Vidéo',
    'isDownloaded': true,
  },
  {
    'title': 'Quiz : Révolution française',
    'description': 'Testez vos connaissances en histoire.',
    'type': 'Exercice',
    'isDownloaded': false,
  },
];
