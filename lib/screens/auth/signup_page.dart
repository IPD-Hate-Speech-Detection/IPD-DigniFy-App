import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dignify/constants/colors.dart';
import 'package:dignify/screens/auth/login_page.dart';
import 'package:dignify/widgets/loading_indicator_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Color myColor;
  late Size mediaSize;
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Container(
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
                    Positioned(top: 80, child: BuildTop()),
                    Positioned(
                      bottom: 0,
                      child: BottomBuild(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget BuildTop() {
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

  Widget BottomBuild() {
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
            "Sign Up",
            style: TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          const Text("Enter Your Full Name"),
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(
              hintText: "Name",
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          const Text("Enter your Email Address"),
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
          const SizedBox(height: 15),
          const Text("Enter new Password"),
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "Password",
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              final passwordRegex =
                  RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$');
              if (!passwordRegex.hasMatch(value)) {
                return 'Password should be at least 8 characters. \nlong and contain at least one uppercase \nletter, one lowercase letter, and one digit';
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
                    // Get.to(() => OtpVerfiicationPage(
                    //     email: _email.text,
                    //     password: _password.text.trim(),
                    //     name: _name.text));

                    createUser();
                  }
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
                child: const Text(
                  "Sign Up",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already have an account?"),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: const Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  createUser() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      Get.offAll(() =>const LoginPage());
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': _name.text,
          'email': _email.text.trim(),
          'password': _password.text.trim(),
          'joinDate': DateTime.now().millisecondsSinceEpoch,
        });

        // print("Firebase response1111 ${response}");
      } catch (exception) {
        print("Error Saving Data at firestore $exception");
      }
    } on FirebaseAuthException catch (e) {
      if (e.message == 'The given password is invalid.') {
        _showToast("Password should be atleast 6 characters long");
      } else if (e.message ==
          'The email address is already in use by another account.') {
        _showToast("Account already exists with this email");
      }
    }
  }

  _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
