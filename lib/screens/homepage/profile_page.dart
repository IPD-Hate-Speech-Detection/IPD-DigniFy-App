import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dignify/constants/colors.dart';
import 'package:dignify/utilities/auth_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  String name = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    if (user != null) {
      email = user!.email ?? "";
      _getUserName(user!.uid);
    }
  }

  Future<void> _getUserName(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          name = userDoc['name'] ?? "Unknown User";
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Name: $name"),
            Text("Email: $email"),
            ElevatedButton(
              onPressed: () {
                _signOut(context);
              },
              style: ButtonStyle(
                shape: WidgetStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all<Color>(primaryColor),
                foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
              ),
              child: const Text("Log Out",style:TextStyle()),
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
      Get.offAll(() => const AuthCheck());
    } catch (error) {
      print('Error signing out user: $error');
    }
  }
}
