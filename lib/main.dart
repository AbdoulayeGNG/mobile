import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/student/student_home_screen.dart';
import 'screens/student/my_courses_screen.dart';
import 'screens/teacher/teacher_home_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/download_manager_screen.dart';
import 'screens/forum_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/teacher/student_tracking_screen.dart';
import 'screens/teacher/student_detail_screen.dart';
import 'models/user_model.dart';

// Clé globale pour la navigation depuis n'importe où
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialiser les timezones
  tz.initializeTimeZones();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey, // Utiliser la clé globale ici
        title: 'Bibliothèque Éducative',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/my-courses': (context) => const MyCoursesScreen(),
          '/download-manager': (context) => const DownloadManagerScreen(),
          '/forum': (context) => const ForumScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/teacher/student-tracking': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, String>;
            return StudentTrackingScreen(
              teacherId: args['teacherId']!,
              classId: args['classId']!,
            );
          },
          '/teacher/student-detail': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
            return StudentDetailScreen(
              student: args['student'],
              teacherId: args['teacherId'],
            );
          },
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!authProvider.isAuthenticated) {
      return const WelcomeScreen();
    } // Redirection selon le rôle de l'utilisateur
    final user = authProvider.currentUser!;
    switch (user.userRole) {
      case UserRole.student:
        return StudentHomeScreen(user: user);
      case UserRole.teacher:
        return TeacherHomeScreen(user: user);
      case UserRole.admin:
        return AdminHomeScreen(user: user);
    }
  }
}
