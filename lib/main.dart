import 'package:flutter/material.dart';
import 'package:khat_husseini/screens/main_navigation_screen.dart';
import 'package:khat_husseini/screens/login_screen.dart';
import 'package:khat_husseini/screens/start_screen.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const bool RESET_DATABASE = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (RESET_DATABASE) {
    await _resetDatabase();
  }

  runApp(const MyApp());
}

Future<void> _resetDatabase() async {
  try {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'khat_husseini.db');

    // Check if the database exists
    final exists = await databaseExists(path);
    if (exists) {
      // Delete the database
      await deleteDatabase(path);
      print('Database reset successfully.');
    }
  } catch (e) {
    print('Error resetting database: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Khat Husseini",
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const StartScreen(),
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainNavigationScreen(),
      },
    );
  }
}
