import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

// Variables d'exemple à placer dans le fichier (au-dessus du build) :
final String? selectedMatiere = 'Mathématiques';
final String? selectedType = null;
final String? selectedDifficulte = null;

final List<Map<String, dynamic>> exercices = [
  {
    'titre': 'QCM sur les équations du 1er degré',
    'description':
        'Testez vos connaissances sur la résolution des équations simples.',
    'type': 'QCM',
    'difficulte': 'Facile',
    'progression': 3,
    'total': 5,
  },
  {
    'titre': 'Problème de calcul mental',
    'description': 'Résolvez des opérations rapidement sans calculatrice.',
    'type': 'Calcul',
    'difficulte': 'Moyen',
    'progression': 0,
    'total': 7,
  },
  {
    'titre': 'Rédaction : Les fractions',
    'description': 'Expliquez comment additionner deux fractions.',
    'type': 'Rédaction',
    'difficulte': 'Difficile',
    'progression': 2,
    'total': 4,
  },
];

class ExercicesScreen extends StatelessWidget {
  final User user;

  const ExercicesScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            const SizedBox(width: 8),
            const Text(
              'Exercices',
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
            _drawerItem(Icons.home, 'Accueil', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
            }),
            _drawerItem(Icons.library_books, 'Bibliothèque', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/bibliotheque');
            }),
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
            // 1. Résumé en haut
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.menu_book, color: Colors.blue, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Mathématiques',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text('Classe : 3ème', style: TextStyle(fontSize: 15)),
                          SizedBox(height: 2),
                          Text(
                            '12 exercices disponibles',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Filtres
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DropdownButton<String>(
                      hint: const Text('Matière'),
                      value: selectedMatiere,
                      items: const [
                        DropdownMenuItem(
                          value: 'Mathématiques',
                          child: Text('Mathématiques'),
                        ),
                        DropdownMenuItem(
                          value: 'Physique',
                          child: Text('Physique'),
                        ),
                        DropdownMenuItem(
                          value: 'Français',
                          child: Text('Français'),
                        ),
                      ],
                      onChanged: (v) {},
                    ),
                    DropdownButton<String>(
                      hint: const Text('Type'),
                      value: selectedType,
                      items: const [
                        DropdownMenuItem(value: 'QCM', child: Text('QCM')),
                        DropdownMenuItem(
                          value: 'Rédaction',
                          child: Text('Rédaction'),
                        ),
                        DropdownMenuItem(
                          value: 'Calcul',
                          child: Text('Calcul'),
                        ),
                      ],
                      onChanged: (v) {},
                    ),
                    DropdownButton<String>(
                      hint: const Text('Difficulté'),
                      value: selectedDifficulte,
                      items: const [
                        DropdownMenuItem(
                          value: 'Facile',
                          child: Text('Facile'),
                        ),
                        DropdownMenuItem(value: 'Moyen', child: Text('Moyen')),
                        DropdownMenuItem(
                          value: 'Difficile',
                          child: Text('Difficile'),
                        ),
                      ],
                      onChanged: (v) {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Liste d'exercices
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exercices.length,
              itemBuilder: (context, index) {
                final ex = exercices[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              ex['type'] == 'QCM'
                                  ? Icons.list_alt
                                  : ex['type'] == 'Rédaction'
                                  ? Icons.edit
                                  : Icons.calculate,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                ex['titre'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    ex['difficulte'] == 'Facile'
                                        ? Colors.green.shade50
                                        : ex['difficulte'] == 'Moyen'
                                        ? Colors.orange.shade50
                                        : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                ex['difficulte'],
                                style: TextStyle(
                                  color:
                                      ex['difficulte'] == 'Facile'
                                          ? Colors.green
                                          : ex['difficulte'] == 'Moyen'
                                          ? Colors.orange
                                          : Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ex['description'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: ex['progression'] / ex['total'],
                                minHeight: 7,
                                backgroundColor: Colors.grey.shade200,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${ex['progression']}/${ex['total']}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              ex['progression'] == 0
                                  ? 'Commencer'
                                  : 'Continuer',
                            ),
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
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }
}
