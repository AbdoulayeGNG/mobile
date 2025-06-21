import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
//import '../models/user_model.dart';
//import 'student/my_courses_screen.dart';
//import 'download_manager_screen.dart';
//import 'forum_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Filtres simulés (à remplacer par ta logique réelle)
  String? selectedLevel;
  String? selectedSubject;
  String? selectedType;
  String searchQuery = '';
  bool isOnline = true; // À remplacer par la vraie détection réseau

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AuthProvider>(context).currentUser;
    final isTeacher = user?.isTeacher() ?? false;
    //final isAdmin = user?.isAdmin() ?? false;
    //final screenSize = MediaQuery.of(context).size;
    //final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Bibliothèque Éducative'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: 'Menu',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
            tooltip: 'Profil',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              accountName: Text(user?.name ?? ''),
              accountEmail: Text(user?.email ?? ''),
            ),
            _drawerItem(Icons.home, 'Accueil', () => Navigator.pop(context)),
            _drawerItem(Icons.library_books, 'Bibliothèque', () {}),
            _drawerItem(Icons.forum, 'Forum', () {}),
            _drawerItem(Icons.analytics, 'Progression', () {}),
            _drawerItem(Icons.settings, 'Paramètres', () {}),
            const Divider(),
            _drawerItem(Icons.logout, 'Déconnexion', () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            }),
          ],
        ),
      ),
      body: Column(
        children: [
          // 2. Zone de filtres
          Container(
            color: theme.primaryColor.withOpacity(0.07),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _filterDropdown('Classe', selectedLevel, ['6ème', '5ème', '4ème', '3ème', '2nde', '1ère', 'Terminale'], (v) => setState(() => selectedLevel = v)),
                _filterDropdown('Matière', selectedSubject, ['Maths', 'Physique', 'Histoire', 'Français'], (v) => setState(() => selectedSubject = v)),
                _filterDropdown('Type', selectedType, ['PDF', 'Vidéo', 'Exercice'], (v) => setState(() => selectedType = v)),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réinitialiser'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () => setState(() {
                    selectedLevel = null;
                    selectedSubject = null;
                    selectedType = null;
                  }),
                ),
              ],
            ),
          ),
          // 3. Zone de recherche rapide
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un cours, un auteur ou un mot-clé…',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => searchQuery = v),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          // 4. Liste des ressources (placeholder)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5, // À remplacer par la vraie liste filtrée
              itemBuilder: (context, i) => _ResourceCard(isDownloaded: i % 2 == 0),
            ),
          ),
          // 6. Statistiques rapides + 7. Indicateur de connectivité
          Container(
            color: theme.primaryColor.withOpacity(0.07),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storage, size: 18),
                    const SizedBox(width: 4),
                    const Text('Ressources: 245'),
                    const SizedBox(width: 12),
                    const Text('Téléchargées: 12'),
                    const SizedBox(width: 12),
                    const Text('Espace: 36 Mo / 512 Mo'),
                  ],
                ),
                Row(
                  children: [
                    Icon(isOnline ? Icons.wifi : Icons.wifi_off, color: isOnline ? Colors.green : Colors.red, size: 18),
                    const SizedBox(width: 4),
                    Text(isOnline ? 'Connecté à Internet' : 'Mode hors ligne activé', style: TextStyle(color: isOnline ? Colors.green : Colors.red)),
                  ],
                ),
              ],
            ),
          ),
          // 8. Footer
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    TextButton(onPressed: () {}, child: const Text('À propos')),
                    TextButton(onPressed: () {}, child: const Text('Aide')),
                    TextButton(onPressed: () {}, child: const Text('Contact')),
                    TextButton(onPressed: () {}, child: const Text('Mentions légales')),
                  ],
                ),
                Row(
                  children: [
                    const Text('v1.0.0'),
                    const SizedBox(width: 8),
                    Image.asset('assets/partner_logo.png', height: 24),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isTeacher
          ? FloatingActionButton.extended(
              backgroundColor: Colors.orange,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une ressource'),
              onPressed: () {
                // Afficher le formulaire d’ajout
              },
            )
          : null,
    );
  }

  Widget _filterDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      value: value,
      hint: Text(label),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final bool isDownloaded;
  const _ResourceCard({this.isDownloaded = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(Icons.picture_as_pdf, color: Colors.red), // À adapter selon le type
        title: const Text('Fonctions du second degré'),
        subtitle: const Text('Cours complet avec exemples et exercices corrigés'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDownloaded)
              Icon(Icons.check_circle, color: Colors.green, size: 20)
            else
              Icon(Icons.cloud_download, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(isDownloaded ? Icons.delete : Icons.download),
              onPressed: () {},
              tooltip: isDownloaded ? 'Supprimer' : 'Télécharger',
            ),
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () {},
              tooltip: 'Consulter',
            ),
          ],
        ),
      ),
    );
  }
}
