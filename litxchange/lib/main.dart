import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import the Firebase core package
import 'firebase_options.dart';
import '/screens/login.dart';
import '/screens/login_signup_page.dart';

// Updated main function to initialize Firebase
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp()); // Run the app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(), // Use LoginSignupPage as the home widget
    );
  }
}