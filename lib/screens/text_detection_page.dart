import 'package:dignify/constants/colors.dart';
import 'package:dignify/widgets/loading_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:dignify/services/text_detection_service.dart';

class TextDetectionPage extends StatefulWidget {
  const TextDetectionPage({super.key});

  @override
  State<TextDetectionPage> createState() => _TextDetectionPageState();
}

class _TextDetectionPageState extends State<TextDetectionPage> {
  final TextEditingController _textDataController = TextEditingController();
  bool _isEnglishSelected = false;
  bool _isHindiSelected = false;
  bool _isMarathiSelected = false;
  String _result = '';
  bool _isLoading = false;

  final TextDetectionService _textDetectionService = TextDetectionService();

  Future<void> _detectHateSpeech() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final id =
          await _textDetectionService.getEventId(_textDataController.text);
      final result = await _textDetectionService.getCompleteResult(id);
      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _result = 'Error: ${e.toString()}';
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
                    labelStyle: TextStyle(
                      color: _isEnglishSelected
                          ? Colors.white
                          : const Color.fromARGB(255, 3, 141, 254),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    checkmarkColor: const Color.fromARGB(255, 3, 255, 12),
                    selected: _isEnglishSelected,
                    selectedColor: Colors.blue,
                    label: const Text('English'),
                    onSelected: (bool selected) {
                      setState(() {
                        _isEnglishSelected = selected;
                        if (selected) {
                          _isHindiSelected = false;
                          _isMarathiSelected = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  FilterChip(
                    labelStyle: TextStyle(
                      color: _isHindiSelected
                          ? Colors.white
                          : const Color.fromARGB(255, 2, 141, 255),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    checkmarkColor: const Color.fromARGB(255, 3, 255, 12),
                    selected: _isHindiSelected,
                    selectedColor: Colors.blue,
                    label: const Text('हिन्दी'),
                    onSelected: (bool selected) {
                      setState(() {
                        _isHindiSelected = selected;
                        if (selected) {
                          _isEnglishSelected = false;
                          _isMarathiSelected = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  FilterChip(
                    labelStyle: TextStyle(
                      color: _isMarathiSelected
                          ? Colors.white
                          : const Color.fromARGB(255, 3, 141, 254),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    checkmarkColor: const Color.fromARGB(255, 3, 255, 12),
                    selected: _isMarathiSelected,
                    selectedColor: Colors.blue,
                    label: const Text('मराठी'),
                    onSelected: (bool selected) {
                      setState(() {
                        _isMarathiSelected = selected;
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
                onPressed: _isLoading ? null : _detectHateSpeech,
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
              const SizedBox(height: 25),
              const Text("Results"),
              const SizedBox(height: 10),
              _isLoading
                  ? const SizedBox(
                      child: Center(
                        child: LoadingIndicatorWidget(),
                      ),
                    )
                  : Text(
                      _result,
                      style: TextStyle(
                        color: _result.startsWith('Error') ||
                                _result.contains("hate")
                            ? Colors.red
                            : Colors.green,
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
