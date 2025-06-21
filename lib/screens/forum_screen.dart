import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

class ForumScreen extends StatefulWidget {
  static const String routeName = '/forum';

  const ForumScreen({Key? key}) : super(key: key);

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showNewPostDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nouvelle question'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Matière'),
                  items: const [
                    DropdownMenuItem(
                      value: 'math',
                      child: Text('Mathématiques'),
                    ),
                    DropdownMenuItem(value: 'physics', child: Text('Physique')),
                    DropdownMenuItem(value: 'french', child: Text('Français')),
                  ],
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    hintText: 'Entrez le titre de votre question',
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Question',
                    hintText: 'Détaillez votre question',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implémenter la création de question
                  Navigator.pop(context);
                },
                child: const Text('Publier'),
              ),
            ],
          ),
    );
  }  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Rechercher...',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    // TODO: Implémenter la recherche
                  },
                )
                : const Text('Forum'),        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          if (user?.isTeacher() == true || user?.isAdmin() == true) ...[
            IconButton(
              icon: const Icon(Icons.flag_outlined),
              onPressed: () {
                // TODO: Afficher la liste des signalements
              },
              tooltip: 'Signalements',
            ),
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                // TODO: Afficher les options de modération
              },
              tooltip: 'Modération',
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Toutes les Questions'),
            Tab(text: 'Ma Classe'),
            Tab(text: 'Mes Questions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiscussionList(false, false),
          _buildDiscussionList(true, false),
          _buildDiscussionList(false, true),
        ],
      ),      floatingActionButton: user != null ? FloatingActionButton.extended(
        onPressed: _showNewPostDialog,
        icon: const Icon(Icons.add),
        label: Text(user.isTeacher() ? 'Nouvelle Annonce' : 'Poser une question'),
        tooltip: user.isTeacher() ? 'Publier une annonce' : 'Poser une question',
      ) : null,
    );
  }

  Widget _buildDiscussionList(bool filterByClass, bool filterByUser) {
    final user = context.read<AuthProvider>().currentUser;
    final bool isTeacherOrAdmin = user?.userRole == UserRole.teacher || user?.userRole == UserRole.admin;

    return ListView.builder(
      itemCount: 10, // À remplacer par la vraie liste
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: const Text('Titre de la question'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Posée par John Doe - il y a 2 heures'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Chip(
                      label: const Text('Mathématiques'),
                      backgroundColor: Colors.blue.withOpacity(0.1),
                    ),
                    const SizedBox(width: 8),
                    const Text('5 réponses'),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_useful',
                  child: Text('Marquer comme utile'),
                ),
                const PopupMenuItem(
                  value: 'report',
                  child: Text('Signaler'),
                ),
                if (isTeacherOrAdmin) ...[
                  const PopupMenuItem(
                    value: 'pin',
                    child: Text('Épingler la discussion'),
                  ),
                  const PopupMenuItem(
                    value: 'close',
                    child: Text('Clore la discussion'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Supprimer'),
                  ),
                ],
              ],
              onSelected: (value) {
                switch (value) {
                  case 'mark_useful':
                    // TODO: Marquer comme utile
                    break;
                  case 'report':
                    _showReportDialog(context);
                    break;
                  case 'pin':
                    // TODO: Épingler la discussion
                    break;
                  case 'close':
                    // TODO: Clore la discussion
                    break;
                  case 'delete':
                    _showDeleteConfirmation(context);
                    break;
                }
              },
            ),
            onTap: () {
              // TODO: Naviguer vers le détail de la question
            },
            isThreeLine: true,
          ),
        );
      },
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler la discussion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pour quelle raison souhaitez-vous signaler cette discussion ?'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Raison',
              ),
              items: const [
                DropdownMenuItem(value: 'inappropriate', child: Text('Contenu inapproprié')),
                DropdownMenuItem(value: 'spam', child: Text('Spam')),
                DropdownMenuItem(value: 'offensive', child: Text('Contenu offensant')),
                DropdownMenuItem(value: 'other', child: Text('Autre')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Commentaire',
                hintText: 'Détaillez votre signalement',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Envoyer le signalement
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signalement envoyé')),
              );
            },
            child: const Text('Signaler'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la discussion'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette discussion ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // TODO: Supprimer la discussion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Discussion supprimée')),
              );
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
