import 'package:dignify/constants/colors.dart';
import 'package:dignify/screens/auth/login_page.dart';
import 'package:dignify/widgets/loading_indicator_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key}) ;

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _email = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Color myColor;
  late Size mediaSize;
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        color: myColor,
        image: DecorationImage(
          image: const AssetImage("assets/images/login_background.jpg"),
          fit: BoxFit.cover,
          colorFilter:
              ColorFilter.mode(myColor.withOpacity(0.9), BlendMode.dstATop),
        ),
      ),
      child: _isLoading
          ? const LoadingIndicatorWidget()
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  Positioned(top: 80, child: buildTop()),
                  Positioned(
                    bottom: 0,
                    child: bottomBuild(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildTop() {
    return SizedBox(
      width: mediaSize.width,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image(
              image: AssetImage("assets/images/loginlogo.png"),
              width: 150,
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget bottomBuild() {
    return SizedBox(
      width: mediaSize.width,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: BuildForm(),
        ),
      ),
    );
  }

  Widget BuildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Change Password",
            style: TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          const Text("Enter Email"),
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(
              hintText: "Email Address",
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email address';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _resetPassword(_email.text.trim());
                  }
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
                child: Text("Send Link"),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _resetPassword(String email) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Password reset link has been sent to your email."),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  // Navigate to another page here
                  Get.offAll(() => const LoginPage());
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.amber),
                ),
                child: const Text(
                  "Okay",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          );
        },
      );
    } catch (error) {
      // Likely "user-not-found" error if email doesn't exist
      if (error.hashCode.toString() == 'user-not-found') {
        _showMessage(
            "This email is not registered. Please check your email address.");
        setState(() {
          _isLoading = false;
        });
      } else {
        print('Error sending password reset email: $error');
        _showMessage('Failed to send password reset email. Please try again.');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 5),
        content: Text(message),
      ),
    );
  }
}
