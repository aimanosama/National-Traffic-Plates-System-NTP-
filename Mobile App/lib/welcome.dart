import 'package:flutter/material.dart';
import 'login.dart';
import 'main.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/top_pattern.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Image.asset(
                        "assets/logo.png",
                        height: constraints.maxHeight * 0.09,
                        errorBuilder: (_, __, ___) => const Icon(Icons.security, size: 80, color: AppColors.primary),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.04),

                      Text(
                        "مرحباً بك!",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "National Traffic Plates System (NTP)",
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'قيادة آمنة وطرق آمنة... بنظامك الموثوق في مصر.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.secondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                        child: const Text(
                          "ابدأ الآن",
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}