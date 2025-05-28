import 'package:flutter/material.dart';
import 'package:khat_husseini/screens/dashboard_screen.dart';
import 'package:khat_husseini/screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Khat Husseini",
      home: DashboardScreen(), 
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen()
      }, 
    );
  }
}