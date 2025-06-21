import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class BibliothequeScreen extends StatelessWidget {
  final User user;
  final bool isTeacher;

  const BibliothequeScreen({super.key, required this.user, this.isTeacher = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            const SizedBox(width: 8),
            const Text('Bibliothèque', style: TextStyle(color: Colors.white, fontSize: 20)),
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
            _drawerItem(Icons.home, 'Accueil', () { Navigator.pop(context);
              Navigator.pushNamed(context, '/');}),
            _drawerItem(Icons.library_books, 'Bibliothèque', () { Navigator.pop(context);
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Zone de filtre
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        DropdownButton<String>(
                          hint: const Text('Classe'),
                          items: const [
                            DropdownMenuItem(value: '6ème', child: Text('6ème')),
                            DropdownMenuItem(value: '5ème', child: Text('5ème')),
                            DropdownMenuItem(value: '4ème', child: Text('4ème')),
                            DropdownMenuItem(value: '3ème', child: Text('3ème')),
                            DropdownMenuItem(value: '2nde', child: Text('2nde')),
                            DropdownMenuItem(value: '1ère', child: Text('1ère')),
                            DropdownMenuItem(value: 'Terminale', child: Text('Terminale')),
                          ],
                          onChanged: (_) {},
                        ),
                        DropdownButton<String>(
                          hint: const Text('Matière'),
                          items: const [
                            DropdownMenuItem(value: 'Maths', child: Text('Maths')),
                            DropdownMenuItem(value: 'Physique', child: Text('Physique')),
                            DropdownMenuItem(value: 'Histoire', child: Text('Histoire')),
                            DropdownMenuItem(value: 'Français', child: Text('Français')),
                          ],
                          onChanged: (_) {},
                        ),
                        DropdownButton<String>(
                          hint: const Text('Type'),
                          items: const [
                            DropdownMenuItem(value: 'PDF', child: Text('PDF')),
                            DropdownMenuItem(value: 'Vidéo', child: Text('Vidéo')),
                            DropdownMenuItem(value: 'Exercice', child: Text('Exercice')),
                          ],
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Barre de recherche
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher une ressource...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Liste de ressources
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: resources.length,
                  itemBuilder: (context, index) {
                    final res = resources[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              res['type'] == 'PDF'
                                  ? Icons.picture_as_pdf
                                  : res['type'] == 'Vidéo'
                                      ? Icons.play_circle_fill
                                      : Icons.edit,
                              color: res['type'] == 'PDF'
                                  ? Colors.red
                                  : res['type'] == 'Vidéo'
                                      ? Colors.blue
                                      : Colors.orange,
                              size: 36,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    res['title'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    res['description'],
                                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      if (res['offline'] == true)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            '✅ Disponible hors ligne',
                                            style: TextStyle(fontSize: 12, color: Colors.green),
                                          ),
                                        ),
                                      const Spacer(),
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          minimumSize: const Size(90, 36),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(res['offline'] == true ? 'Consulter' : 'Télécharger'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // 4. FAB enseignant
          if (isTeacher)
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton.extended(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une ressource'),
                backgroundColor: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }
}

// Exemple de données à placer dans le fichier ou à remplacer par ta logique :
final List<Map<String, dynamic>> resources = [
  {
    'title': 'Fonctions du second degré',
    'description': 'Cours PDF complet avec exercices corrigés.',
    'type': 'PDF',
    'offline': false,
  },
  {
    'title': 'Les bases de la chimie',
    'description': 'Vidéo explicative pour débutants.',
    'type': 'Vidéo',
    'offline': true,
  },
  {
    'title': 'Quiz : Révolution française',
    'description': 'Testez vos connaissances en histoire.',
    'type': 'Exercice',
    'offline': false,
  },
];