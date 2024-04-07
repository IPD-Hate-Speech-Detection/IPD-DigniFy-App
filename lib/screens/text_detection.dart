import 'package:dignify/constants/colors.dart';
import 'package:flutter/material.dart';

class TextDetectionPage extends StatefulWidget {
  const TextDetectionPage({super.key});

  @override
  State<TextDetectionPage> createState() => _TextDetectionPageState();
}

class _TextDetectionPageState extends State<TextDetectionPage> {
  final TextEditingController _textDataController = TextEditingController();
  bool _isEnglishSelected = false;
  bool _isHindiSelected = false;
  bool _isOthersSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text Detection"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text(
                  "Hate Speech Detector",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 197, 196, 196),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Please select a Language",
                style: TextStyle(color: Color.fromARGB(255, 193, 191, 191)),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  FilterChip(
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 103, 183, 248),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    checkmarkColor: Colors.green,
                    selected: _isEnglishSelected,
                    label: const Text('English'),
                    onSelected: (bool selected) {
                      setState(() {
                        _isEnglishSelected = selected;
                        if (selected) {
                          _isHindiSelected = false;
                          _isOthersSelected = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  FilterChip(
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 103, 183, 248),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    checkmarkColor: Colors.green,
                    selected: _isHindiSelected,
                    label: const Text('हिन्दी'),
                    onSelected: (bool selected) {
                      setState(() {
                        _isHindiSelected = selected;
                        if (selected) {
                          _isEnglishSelected = false;
                          _isOthersSelected = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  FilterChip(
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 103, 183, 248),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    checkmarkColor: Colors.green,
                    selected: _isOthersSelected,
                    label: const Text('मराठी'),
                    onSelected: (bool selected) {
                      setState(() {
                        _isOthersSelected = selected;
                        if (selected) {
                          _isEnglishSelected = false;
                          _isHindiSelected = false;
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Text(
                "Enter text",
                style: TextStyle(color: Color.fromARGB(255, 193, 191, 191)),
              ),
              const SizedBox(height: 15),
              TextFormField(
                maxLines: 5,
                controller: _textDataController,
                decoration: const InputDecoration(
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
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
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
                  "Detect Hate Speech",
                ),
              ),
              const SizedBox(height: 25),
              const Text("Results")
            ],
          ),
        ),
      ),
    );
  }
}
