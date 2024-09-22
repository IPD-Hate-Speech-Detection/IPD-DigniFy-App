import 'package:dignify/constants/colors.dart';
import 'package:dignify/services/image_detection.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ImageDetectionPage extends StatefulWidget {
  const ImageDetectionPage({super.key});

  @override
  State<ImageDetectionPage> createState() => _ImageDetectionPageState();
}

class _ImageDetectionPageState extends State<ImageDetectionPage> {
  bool _isLoading = false;
  String? _filePath;
  var _result = ' ';
  final ImageHateService _imageHateService = ImageHateService();

  Future<void> _pickImage() async {
    print("clicked");
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (pickedFile != null) {
      setState(() {
        _filePath = pickedFile.files.single.path;
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> _uploadImage() async {
    if (_filePath == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final File imageFile = File(_filePath!);
      final result = await _imageHateService.detectHateSpeech(imageFile);
      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Detection"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text(
                  "Detect Hate Speech in Images",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueGrey),
                ),
                height: 200,
                child: _filePath != null
                    ? Image.file(
                        File(_filePath!),
                        fit: BoxFit.contain,
                      )
                    : const Center(child: Text("No image picked")),
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: _pickImage,
                child: Center(
                  child: Container(
                    height: 50,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 78, 77, 77)),
                      // color: const Color.fromARGB(255, 154, 180, 193),
                    ),
                    child: const Center(
                      child: Text(
                        "Pick Image",
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        FocusScope.of(context).unfocus();
                        _uploadImage();
                        // Call your image detection function here
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
                  "Detect Hate Speech",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              const Text("Results"),
              Text(_result),
            ],
          ),
        ),
      ),
    );
  }
}
