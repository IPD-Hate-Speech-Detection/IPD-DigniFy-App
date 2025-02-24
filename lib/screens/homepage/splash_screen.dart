import 'dart:async';
import 'package:dignify/constants/colors.dart';
import 'package:dignify/utilities/auth_check.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentPage < 2) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } else {
        timer.cancel();
        Future.delayed(const Duration(seconds: 2), () {
          Get.off(() => const AuthCheck());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          Center(
            child: Text(
              "DigniFy",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          Center(
            child: Text(
              "Detect Hate. Prevent Harm. Unite Communities.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "©Copyright DJSCE, 2025",
                  style: TextStyle(fontSize: 12, color: primaryColor),
                ),
                SizedBox(height: 8),
                Text(
                  "Shubham Jaiswar(60004220112)\n"
                  "Siddhant Uniyal(60004220202)\n"
                  "Tirath Bhatawala(60004220101)\n"
                  "Vikas Kewat(60004220181)",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
