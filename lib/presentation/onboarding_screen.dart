import 'package:flutter/material.dart';
import 'package:smart_pillbox/presentation/introduction/intro_screen1.dart';
import 'package:smart_pillbox/presentation/introduction/intro_screen2.dart';
import 'package:smart_pillbox/presentation/introduction/intro_screen3.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'authentication/signin.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool _onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _onLastPage = (index == 2);
              });
            },
            children: const [IntroScreen1(), IntroScreen2(), IntroScreen3()],
          ),
          Container(
            alignment: const Alignment(0, 0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SigninScreen(),
                      ),
                      (route) => false, // Remove all previous routes
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 25.0), // Increased padding
                    child: Text(
                      'Skip',
                      style: TextStyle(fontSize: 18), // Increased font size
                    ),
                  ),
                ),
                SmoothPageIndicator(controller: _controller, count: 3),
                _onLastPage
                    ? GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SigninScreen(),
                            ),
                            (route) => false, // Remove all previous routes
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 15.0,
                              horizontal: 25.0), // Increased padding
                          child: Text(
                            'Done',
                            style:
                                TextStyle(fontSize: 18), // Increased font size
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          _controller.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeIn);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 15.0,
                              horizontal: 25.0), // Increased padding
                          child: Text(
                            'Next',
                            style:
                                TextStyle(fontSize: 18), // Increased font size
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
