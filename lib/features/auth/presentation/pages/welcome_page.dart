import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/core/app_colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;

    const colorizeColors = [
      Colors.black,
      Colors.blue,
      Colors.white,
    ];

    final colorizeTextStyle = textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(AppColors.authBackgroundUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.1),
                  Image.network(
                    AppColors.logoUrl,
                    width: 200,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.flutter_dash,
                        size: 200,
                        color: Colors.white,
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  AnimatedTextKit(
                    animatedTexts: [
                      ColorizeAnimatedText(
                        'Welcome to NTP',
                        textStyle: colorizeTextStyle!,
                        colors: colorizeColors,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    isRepeatingAnimation: true,
                    repeatForever: true,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go('/login'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: const BorderSide(color: Colors.white),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'Login',
                        style: textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go('/signup'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: const BorderSide(color: Colors.white),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'Sign Up',
                        style: textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
