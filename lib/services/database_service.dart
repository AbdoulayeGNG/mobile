import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/course_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    return await _getDatabase();
  }

  Future<Database> _getDatabase() async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'codewario.db');

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        profile_image TEXT,
        phone_number TEXT,
        level_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (level_id) REFERENCES levels (id)
      )
    ''');

    // User preferences table
    await db.execute('''
      CREATE TABLE user_preferences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        key TEXT NOT NULL,
        value TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Courses table
    await db.execute('''
      CREATE TABLE courses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        author_id TEXT NOT NULL,
        level_id TEXT NOT NULL,
        grade_id TEXT NOT NULL,
        subject_id TEXT NOT NULL,
        type TEXT NOT NULL,
        content TEXT NOT NULL,
        file_path TEXT,
        is_downloaded INTEGER DEFAULT 0,
        last_accessed_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (author_id) REFERENCES users (id),
        FOREIGN KEY (level_id) REFERENCES levels (id),
        FOREIGN KEY (grade_id) REFERENCES grades (id),
        FOREIGN KEY (subject_id) REFERENCES subjects (id)
      )
    ''');

    // Course progress table
    await db.execute('''
      CREATE TABLE course_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        course_id TEXT NOT NULL,
        progress REAL NOT NULL DEFAULT 0,
        completion_status TEXT NOT NULL DEFAULT 'not_started',
        last_position TEXT,
        started_at TEXT NOT NULL,
        completed_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (course_id) REFERENCES courses (id)
      )
    ''');

    // Quiz results table for tracking attempts and scores
    await db.execute('''
      CREATE TABLE quiz_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        course_id TEXT NOT NULL,
        quiz_id TEXT NOT NULL,
        score REAL NOT NULL,
        user_answers TEXT NOT NULL,
        is_practice_mode INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (course_id) REFERENCES courses (id)
      )
    ''');

    // Quizzes table for storing quiz configurations
    await db.execute('''
      CREATE TABLE quizzes (
        id TEXT PRIMARY KEY,
        course_id TEXT NOT NULL,
        title TEXT NOT NULL,
        passing_score INTEGER NOT NULL,
        time_limit INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (course_id) REFERENCES courses (id)
      )
    '''); // Subjects table
    await db.execute('''
      CREATE TABLE subjects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        icon_name TEXT NOT NULL,
        color TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Levels table (Niveaux scolaires)
    await db.execute('''
      CREATE TABLE levels (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        order_num INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Grades table (Classes)
    await db.execute('''
      CREATE TABLE grades (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        level_id TEXT NOT NULL,
        description TEXT,
        order_num INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (level_id) REFERENCES levels (id)
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        content_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        created_at TEXT NOT NULL,
        scheduled_for TEXT,
        read INTEGER NOT NULL DEFAULT 0,
        delivered INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Teacher comments table
    await db.execute('''
      CREATE TABLE teacher_comments (
        id TEXT PRIMARY KEY,
        teacher_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        comment TEXT NOT NULL,
        created_at TEXT NOT NULL,
        course_id TEXT,
        quiz_id TEXT,
        FOREIGN KEY (teacher_id) REFERENCES users (id),
        FOREIGN KEY (student_id) REFERENCES users (id),
        FOREIGN KEY (course_id) REFERENCES courses (id),
        FOREIGN KEY (quiz_id) REFERENCES quizzes (id)
      )
    ''');

    // Classes table
    await db.execute('''
      CREATE TABLE classes (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        teacher_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (teacher_id) REFERENCES users (id)
      )
    ''');

    // User-Class relation
    await db.execute('''
      CREATE TABLE user_classes (
        user_id TEXT NOT NULL,
        class_id TEXT NOT NULL,
        joined_at TEXT NOT NULL,
        PRIMARY KEY (user_id, class_id),
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (class_id) REFERENCES classes (id)
      )
    ''');

    // Insérer les données initiales
    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Insérer les niveaux
    final levels = [
      {
        'id': 'level_college',
        'name': 'Collège',
        'description': 'Niveau collège (7ème à 9ème année)',
        'order_num': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'level_lycee',
        'name': 'Lycée',
        'description': 'Niveau lycée (10ème à 12ème année)',
        'order_num': 2,
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (final level in levels) {
      await db.insert('levels', level);
    }

    // Insérer les années (grades)
    final grades = [
      {
        'id': 'grade_7',
        'name': '7ème année',
        'level_id': 'level_college',
        'description': 'Première année du collège',
        'order_num': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'grade_8',
        'name': '8ème année',
        'level_id': 'level_college',
        'description': 'Deuxième année du collège',
        'order_num': 2,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'grade_9',
        'name': '9ème année',
        'level_id': 'level_college',
        'description': 'Troisième année du collège',
        'order_num': 3,
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (final grade in grades) {
      await db.insert('grades', grade);
    }

    // Insérer les matières
    final subjects = [
      {
        'id': 'subject_math',
        'name': 'Mathématiques',
        'description': 'Cours de mathématiques',
        'icon_name': 'calculate',
        'color': '#2196F3',
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'subject_physics',
        'name': 'Physique',
        'description': 'Cours de physique',
        'icon_name': 'science',
        'color': '#4CAF50',
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'subject_french',
        'name': 'Français',
        'description': 'Cours de français',
        'icon_name': 'book',
        'color': '#FF9800',
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (final subject in subjects) {
      await db.insert('subjects', subject);
    }

    // Insérer un professeur par défaut
    final defaultTeacher = {
      'id': 'teacher_default',
      'email': 'prof@codewario.com',
      'password':
          'prof123', // À hasher dans un vrai environnement de production
      'name': 'Prof Principal',
      'role': 'teacher',
      'created_at': now,
      'updated_at': now,
    };

    await db.insert('users', defaultTeacher);

    // Insérer des cours de test
    final courses = [
      {
        'id': 'course_math_1',
        'title': 'Introduction à l\'algèbre',
        'description':
            'Cours d\'introduction aux concepts de base de l\'algèbre',
        'subject_id': 'subject_math',
        'grade_id': 'grade_7',
        'level_id': 'level_college',
        'author_id': 'teacher_default',
        'type': 'pdf',
        'content': '',
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'course_physics_1',
        'title': 'Les forces et le mouvement',
        'description': 'Introduction à la mécanique et aux forces',
        'subject_id': 'subject_physics',
        'grade_id': 'grade_7',
        'level_id': 'level_college',
        'author_id': 'teacher_default',
        'type': 'pdf',
        'content': '',
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'course_french_1',
        'title': 'Grammaire - Les verbes',
        'description': 'Les bases de la conjugaison française',
        'subject_id': 'subject_french',
        'grade_id': 'grade_7',
        'level_id': 'level_college',
        'author_id': 'teacher_default',
        'type': 'pdf',
        'content': '',
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (final course in courses) {
      await db.insert('courses', course);
    }
  }

  // User authentication and operations
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> results = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (results.isNotEmpty) {
        return User.fromJson(results.first);
      }
      return null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  Future<User?> authenticateUser(String email, String password) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> results = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [
          email,
          password,
        ], // Note: Dans un vrai projet, utiliser un hash du mot de passe
      );

      if (results.isNotEmpty) {
        return User.fromJson(results.first);
      }
      return null;
    } catch (e) {
      print('Error authenticating user: $e');
      return null;
    }
  }

  Future<User?> getUserById(String id) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> results = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (results.isNotEmpty) {
        return User.fromJson(results.first);
      }
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  Future<void> createUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // Gestion de l'utilisateur connecté
  Future<void> saveLastLoggedInUserId(String userId) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    // On supprime d'abord tous les enregistrements précédents
    await db.delete(
      'user_preferences',
      where: 'key = ?',
      whereArgs: ['last_logged_in_user'],
    );

    // On insère le nouvel ID
    await db.insert('user_preferences', {
      'key': 'last_logged_in_user',
      'value': userId,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<String?> getLastLoggedInUserId() async {
    final db = await database;
    final results = await db.query(
      'user_preferences',
      where: 'key = ?',
      whereArgs: ['last_logged_in_user'],
    );

    if (results.isNotEmpty) {
      return results.first['value'] as String?;
    }
    return null;
  }

  // Course operations
  Future<List<Course>> getAllCourses() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'courses',
        orderBy: 'created_at DESC',
      );

      return maps
          .map(
            (map) => Course(
              id: map['id'] as String,
              title: map['title'] as String,
              description: map['description'] as String,
              authorId: map['teacher_id'] as String,
              levelId: map['level_id'] as String,
              gradeId: map['grade_id'] as String,
              subjectId: map['subject_id'] as String,
              type: map['file_type'] as String? ?? 'pdf',
              content:
                  map['content'] as String? ?? map['description'] as String,
              filePath: map['file_path'] as String?,
              isDownloaded: (map['is_downloaded'] as int?) == 1,
              lastAccessedAt: map['last_accessed_at'] as String?,
              createdAt: map['created_at'] as String,
              updatedAt: map['updated_at'] as String,
            ),
          )
          .toList();
    } catch (e) {
      print('Error getting all courses: $e');
      return [];
    }
  }

  // Course download operations
  Future<void> updateCourseDownloadStatus({
    required String courseId,
    required bool isDownloaded,
    String? filePath,
  }) async {
    try {
      final db = await database;
      await db.update(
        'courses',
        {
          'is_downloaded': isDownloaded ? 1 : 0,
          'file_path': filePath,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [courseId],
      );
    } catch (e) {
      print('Erreur lors de la mise à jour du statut de téléchargement: $e');
      rethrow;
    }
  }

  // Récupérer le courseId associé à un quiz
  Future<String?> getCourseIdForQuiz(String quizId) async {
    final db = await database;
    final results = await db.query(
      'quizzes',
      columns: ['course_id'],
      where: 'id = ?',
      whereArgs: [quizId],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return results.first['course_id'] as String;
    }
    return null;
  }

  // Récupérer un cours par son ID
  Future<Course?> getCourse(String courseId) async {
    final db = await database;
    final results = await db.query(
      'courses',
      where: 'id = ?',
      whereArgs: [courseId],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return Course.fromJson(results.first);
    }
    return null;
  }

  Future<List<Course>> getDownloadedCourses() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> results = await db.query(
        'courses',
        where: 'file_path IS NOT NULL AND file_path != ""',
      );

      return results.map((map) => Course.fromJson(map)).toList();
    } catch (e) {
      print('Error getting downloaded courses: $e');
      return [];
    }
  }

  // Récupérer la progression d'un cours pour un utilisateur
  Future<Map<String, dynamic>?> getCourseProgress(
    String userId,
    String courseId,
  ) async {
    final db = await database;
    final results = await db.query(
      'course_progress',
      where: 'user_id = ? AND course_id = ?',
      whereArgs: [userId, courseId],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Récupérer la progression de tous les cours d'un utilisateur
  Future<Map<String, double>> getUserProgressBySubject(String userId) async {
    final db = await database;
    final results = await db.rawQuery(
      '''
      SELECT s.name as subject_name, 
             AVG(cp.progress) as avg_progress
      FROM subjects s
      JOIN courses c ON c.subject_id = s.id
      LEFT JOIN course_progress cp ON cp.course_id = c.id AND cp.user_id = ?
      GROUP BY s.id, s.name
    ''',
      [userId],
    );

    Map<String, double> progressBySubject = {};
    for (var row in results) {
      progressBySubject[row['subject_name'] as String] =
          ((row['avg_progress'] as num?) ?? 0.0).toDouble();
    }
    return progressBySubject;
  }

  // Récupérer les derniers cours consultés
  Future<List<Course>> getRecentCourses(String userId, {int limit = 5}) async {
    final db = await database;
    final results = await db.rawQuery(
      '''
      SELECT c.*
      FROM courses c
      JOIN course_progress cp ON cp.course_id = c.id
      WHERE cp.user_id = ?
      ORDER BY cp.last_position IS NULL DESC, 
               cp.last_position DESC,
               cp.started_at DESC
      LIMIT ?
    ''',
      [userId, limit],
    );

    return results.map((row) => Course.fromJson(row)).toList();
  }

  // Récupérer les recommandations de cours
  Future<List<Course>> getRecommendedCourses(
    String userId, {
    int limit = 5,
  }) async {
    final db = await database;
    // Recommande des cours basés sur le niveau de l'utilisateur
    // et les matières où la progression est la plus faible
    final results = await db.rawQuery(
      '''
      WITH UserProgress AS (
        SELECT s.id as subject_id, AVG(cp.progress) as avg_progress
        FROM subjects s
        LEFT JOIN courses c ON c.subject_id = s.id
        LEFT JOIN course_progress cp ON cp.course_id = c.id AND cp.user_id = ?
        GROUP BY s.id
      )
      SELECT c.*
      FROM courses c
      JOIN users u ON u.level_id = c.level_id
      JOIN UserProgress up ON up.subject_id = c.subject_id
      LEFT JOIN course_progress cp ON cp.course_id = c.id AND cp.user_id = ?
      WHERE u.id = ?
        AND (cp.id IS NULL OR cp.completion_status != 'completed')
      ORDER BY up.avg_progress ASC, c.created_at DESC
      LIMIT ?
    ''',
      [userId, userId, userId, limit],
    );

    return results.map((row) => Course.fromJson(row)).toList();
  }

  // Mettre à jour la progression d'un cours
  Future<void> updateCourseProgress(
    String userId,
    String courseId,
    double progress, {
    String? lastPosition,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final existingProgress = await getCourseProgress(userId, courseId);

    if (existingProgress == null) {
      await db.insert('course_progress', {
        'user_id': userId,
        'course_id': courseId,
        'progress': progress,
        'completion_status': progress >= 1.0 ? 'completed' : 'in_progress',
        'last_position': lastPosition,
        'started_at': now,
        'completed_at': progress >= 1.0 ? now : null,
      });
    } else {
      await db.update(
        'course_progress',
        {
          'progress': progress,
          'completion_status': progress >= 1.0 ? 'completed' : 'in_progress',
          'last_position': lastPosition,
          'completed_at': progress >= 1.0 ? now : null,
        },
        where: 'user_id = ? AND course_id = ?',
        whereArgs: [userId, courseId],
      );
    }
  }

  // Clean up
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
