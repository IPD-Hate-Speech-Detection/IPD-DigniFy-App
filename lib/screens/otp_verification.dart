import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dignify/constants/colors.dart';
import 'package:dignify/screens/login_page.dart';
import 'package:dignify/widgets/loading_indicator_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'dart:convert';
import 'dart:math';

class OtpVerfiicationPage extends StatefulWidget {
  final String email;
  final String password;
  final String name;
  const OtpVerfiicationPage(
      {Key? key,
      required this.email,
      required this.password,
      required this.name})
      : super(key: key);

  @override
  State<OtpVerfiicationPage> createState() => _OtpVerfiicationPageState();
}

class _OtpVerfiicationPageState extends State<OtpVerfiicationPage> {
  final TextEditingController _otp = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Color myColor;
  late Size mediaSize;
  late int generatedOtp;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    generatedOtp = generateOTP();
    print(generatedOtp);
    sendMail();
  }

  int generateOTP() {
    Random random = Random();

    return 100000 + random.nextInt(900000);
  }

  Future<void> sendMail() async {
    try {
      setState(() {
        _isLoading = true;
      });
      // Define the API endpoint URL
      String url = 'https://api.mailersend.com/v1/email';

      // Define the request body
      Map<String, dynamic> requestBody = {
        "from": {
          "email": "dignify@trial-z3m5jgrqr7xldpyo.mlsender.net"
        }, // Use trial domain as sender domain
        "to": [
          {
            "email": widget.email // Corrected the format
          }
        ],
        "subject": "OTP Verification",
        "text": "Your OTP is ${generatedOtp}",
        "html": "Your OTP is ${generatedOtp}"
      };

      // Make the HTTP POST request
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'Authorization':
              'Bearer mlsn.33a70e638f167b71167bd8841880700d313d675e43db8a1cf377bf80b636ddb2', // Replace 'YOUR_TOKEN' with your actual MailerSend API token
        },
        body: json.encode(requestBody),
      );

      // Check the response status code
      if (response.statusCode == 200) {
        print('Email sent successfully');
        setState(() {
          _isLoading = false;
        });
      } else {
        print('Failed to send email. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          _isLoading = false;
        });
        // Handle the error accordingly
      }
    } catch (error) {
      print('Error sending email: $error');
      // Handle the error accordingly
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        color: myColor,
        image: DecorationImage(
          image: AssetImage("assets/images/login_background.jpg"),
          fit: BoxFit.cover,
          colorFilter:
              ColorFilter.mode(myColor.withOpacity(0.9), BlendMode.dstATop),
        ),
      ),
      child: _isLoading
          ? LoadingIndicatorWidget()
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  Positioned(top: 80, child: BuildTop()),
                  Positioned(
                    child: BottomBuild(),
                    bottom: 0,
                  ),
                ],
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
            "Email OTP Verification",
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text("Enter the OTP sent to your email"),
          TextFormField(
            controller: _otp,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: "OTP",
              prefixIcon: Icon(Icons.security),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the OTP';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_otp.text == generatedOtp.toString()) {
                      print("otp verified");
                      CreateUser();
                    } else {
                      print("Wrong Otp");
                    }
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
                  "Verify Email",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  CreateUser() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );
      Get.offAll(() => LoginPage());
      try {
        var response =
            await FirebaseFirestore.instance.collection('userlist').add({
          'user_Id': userCredential.user!.uid,
          'name': widget.name,
          'email': widget.email.trim(),
          'password': widget.password.trim(),
          'joinDate': DateTime.now().millisecondsSinceEpoch,
        });

        print("Firebase response1111 ${response.id}");
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
