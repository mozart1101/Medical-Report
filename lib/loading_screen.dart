import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    // Simulate a loading delay
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OnboardingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF672E3A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_hospital_outlined, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 10),
            Text("Loading Patient Portal...", style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}