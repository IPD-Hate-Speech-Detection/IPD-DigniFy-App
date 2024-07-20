import 'package:dignify/constants/colors.dart';
import 'package:dignify/screens/otp_verification.dart';
import 'package:dignify/widgets/loading_indicator_widget.dart';
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
            image: AssetImage("assets/images/login_background.jpg"),
            fit: BoxFit.cover,
            colorFilter:
                ColorFilter.mode(myColor.withOpacity(0.9), BlendMode.dstATop),
          ),
        ),
        child:_isLoading?const LoadingIndicatorWidget(): Scaffold(
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
      child: Column(
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
          padding: EdgeInsets.all(32.0),
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
          SizedBox(height: 20),
          Text("Enter Your Full Name"),
          TextFormField(
            controller: _name,
            decoration: InputDecoration(
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
          SizedBox(height: 15),
          Text("Enter your Email Address"),
          TextFormField(
            controller: _email,
            decoration: InputDecoration(
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
          SizedBox(height: 15),
          Text("Enter new Password"),
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(
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
          SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  
                  if (_formKey.currentState!.validate()) {
                    Get.to(() => OtpVerfiicationPage(
                        email: _email.text,
                        password: _password.text.trim(),
                        name: _name.text));
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
                child: Text("Sign Up"),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an account?"),
              SizedBox(width: 5),
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
}
