import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'onboarding_screen.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBXKksE5BEJA4idDGCxaxsf1SNH6_YUCCs', 
      appId: '1:245005786812:web:3156bb6c2e579290c9bab9',
      messagingSenderId: '245005786812',
      projectId: 'pysch-project',
      authDomain: 'pysch-project.firebaseapp.com', 
      storageBucket: 'pysch-project.firebasestorage.app', 
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medical Portal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF672E3A)),
        useMaterial3: true,
      ),
      
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.hasData) {
            return const HomeScreen();
          }

          return const OnboardingScreen();
        },
      ),
    );
  }
}