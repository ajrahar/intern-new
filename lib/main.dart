import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import the provider package
import 'universal_screen/link_provider.dart'; // Correct import path for LinkProvider
import 'admin_screens/home_screen.dart';
import 'universal_screen/login_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LinkProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kodegiri App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        // Add other routes here
      },
    );
  }
}
