import 'package:dignify/constants/colors.dart';
import 'package:dignify/widgets/loading_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:dignify/services/image_detection_service.dart';

class ImageDetectionPage extends StatefulWidget {
  const ImageDetectionPage({super.key});

  @override
  State<ImageDetectionPage> createState() => _ImageDetectionPageState();
}

class _ImageDetectionPageState extends State<ImageDetectionPage> {
  bool _isLoading = false;
  String? _filePath;
  String _result = '';
  late ImageHateDetection _imageHateDetection;

  @override
  void initState() {
    super.initState();
    _imageHateDetection = ImageHateDetection();
  }

  Future<void> _pickImage() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (pickedFile != null) {
      setState(() {
        _filePath = pickedFile.files.single.path ?? '';
        _result = '';
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_filePath == null || _filePath!.isEmpty) {
      _showErrorDialog("No image selected");
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final response = await _imageHateDetection.uploadImage(_filePath);
      final prediction = response['prediction'] as Map<String, dynamic>;

      final String predictionType = prediction['prediction'] ?? 'unknown';
      final String label = prediction['label'] ?? 'unknown';
      final double confidence = prediction['confidence'] ?? 0.0;
      final String language = prediction['language'] ?? 'Not available';
      final String hateText = prediction['hate_text'] ?? 'Not available';

      setState(() {
        if (predictionType == "hate") {
          _result = "The provided image contains Hateful Element(s)\n"
              "Detected Element: $label\n"
              "Confidence: ${(confidence * 100).toStringAsFixed(2)}%\n"
              "Language: $language\n"
              "Hate Text: $hateText";
        } else {
          _result = "The provided image does not contain Hateful Element";
        }
      });
    } catch (e) {
      setState(() {
        _result = '';
      });
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
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
                  "Pick an Image to Detect",
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
                child: _filePath != null && _filePath!.isNotEmpty
                    ? Image.file(
                        File(_filePath!),
                        fit: BoxFit.contain,
                      )
                    : const Center(child: Text("No image picked")),
              ),
              const SizedBox(height: 15),
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blueGrey),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: _isLoading ? null : _pickImage,
                  child: const Text("Pick Image"),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
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
                onPressed: _isLoading ? null : _uploadImage,
                child: const Text(
                  "Detect Hate Speech",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              const Text("Results:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _isLoading
                  ? const Center(child: LoadingIndicatorWidget())
                  : Text(
                      _result,
                      style: TextStyle(
                        color: _result.contains('contains')
                            ? Colors.red
                            : (_result.startsWith('Error:')
                                ? Colors.blue
                                : Colors.green),
                        fontSize: 16,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
