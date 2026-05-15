import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controller to keep track of which page we're on
  final PageController _controller = PageController();
  bool onLastPage = false;

  final Color burgundy = const Color(0xFF672E3A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // THE SLIDING PAGES
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2); // 2 is the index of the 3rd page
              });
            },
            children: [
              _buildPage(
                color: Colors.white,
                icon: Icons.health_and_safety_rounded,
                title: "Welcome to Medical Portal",
                subtitle: "A secure environment designed for healthcare professionals to manage patient data efficiently.",
              ),
              _buildPage(
                color: Colors.white,
                icon: Icons.storage_rounded,
                title: "Live Database Logs",
                subtitle: "Track patient visits in real-time. Every entry is securely synced to our encrypted cloud database.",
              ),
              _buildPage(
                color: Colors.white,
                icon: Icons.lock_person_rounded,
                title: "Authorized Access Only",
                subtitle: "Your data is protected. Only verified staff accounts can access the patient dashboard and logs.",
              ),
            ],
          ),

          // BOTTOM UI (Indicator and Buttons)
          Container(
            alignment: const Alignment(0, 0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Skip Button
                GestureDetector(
                  onTap: () => _controller.jumpToPage(2),
                  child: const Text("Skip", style: TextStyle(fontWeight: FontWeight.bold)),
                ),

                // Dot Indicator
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: ExpandingDotsEffect(
                    activeDotColor: burgundy,
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                ),

                // Next or Done Button
                onLastPage
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: Text("Done", style: TextStyle(fontWeight: FontWeight.bold, color: burgundy)),
                      )
                    : GestureDetector(
                        onTap: () => _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        ),
                        child: const Text("Next", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build the individual pages
  Widget _buildPage({required Color color, required IconData icon, required String title, required String subtitle}) {
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: burgundy),
          const SizedBox(height: 60),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}