import 'package:dignify/screens/auth/change_password.dart';
import 'package:dignify/utilities/auth_check.dart';
import 'package:dignify/widgets/loading_indicator_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dignify/constants/colors.dart';
import 'package:dignify/screens/auth/signup_page.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  late Color myColor;
  late Size mediaSize;
  var _isObscure = true;
  final _formKey = GlobalKey<FormState>();
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
          colorFilter: ColorFilter.mode(
            myColor.withOpacity(0.9),
            BlendMode.dstATop,
          ),
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
          padding:const EdgeInsets.all(32.0),
          child: buildForm(),
        ),
      ),
    );
  }

  Widget buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
       const   Text(
            "Welcome",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w500,
            ),
          ),
       const   Text("Please Login"),
       const   SizedBox(height: 30),
          buildGreyText("Email Address"),
          TextFormField(
            controller: _email,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: "Enter your Email",
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey, width: 2),
              ),
            ),
            cursorColor: Colors.white,
            cursorHeight: 20,
          ),
         const SizedBox(height: 15),
          buildGreyText("Password"),
          TextFormField(
            controller: _password,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
            obscureText: _isObscure,
            decoration: InputDecoration(
              hintText: "Enter your Password",
              prefixIcon:const Icon(Icons.lock),
              suffixIcon: IconButton(
                onPressed: () {
                  _togglePasswordVisibility();
                },
                icon:
                    Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
              ),
              border:const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey),
              ),
              focusedBorder:const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey, width: 2),
              ),
            ),
            cursorColor: Colors.white,
            cursorHeight: 20,
          ),
         const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(() =>const ChangePassword());
                },
                child:const Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, proceed with login
                    signIn();
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
                child: const Text(
                  "Login",
                ),
              ),
            ),
          ),
         const SizedBox(height: 10), 
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              const  Text("Don't have an account?"),
               const SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    Get.to(()=>const SignUpPage());
                  },
                  child: const Text(
                    "Signup",
                    style: TextStyle(
                      color: Colors.blue,
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

  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  Widget buildGreyText(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.grey),
    );
  }

  signIn() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text, password: _password.text);
      print("login successful");
      setState(() {
        _isLoading = false;
      });
      Get.offAll(() =>const AuthCheck());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
        setState(() {
          _isLoading = false;
        });
        _showToast("Incorrect Login Credentials");
      } else {
        print(e);
        setState(() {
          _isLoading = false;
        });
        _showToast("Incorrect Login Credentials");
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
