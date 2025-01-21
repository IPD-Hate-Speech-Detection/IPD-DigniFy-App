import 'package:dignify/constants/colors.dart';
import 'package:dignify/utilities/auth_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatelessWidget {
 const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String name = user?.displayName ?? "okay";
    String email = user?.email ?? "";

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(email),
            ElevatedButton(
              onPressed: () {
                _signOut(context);
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(primaryColor),
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.black),
              ),
              child: const Text(
                "Log Out",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      print('User signed out successfully');
      Get.offAll(() =>const AuthCheck());
    } catch (error) {
      print('Error signing out user: $error');
    }
  }
}
