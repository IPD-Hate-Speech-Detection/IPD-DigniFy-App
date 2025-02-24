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
  bool _isHinglishSelected = false;
  String _result = '';
  bool _isLoading = false;
  var _resultColor;

  final EnglishTextDetectionService _englishTextDetectionService =
      EnglishTextDetectionService();
  final HinglishTextDetectionService _hinglishTextDetectionService =
      HinglishTextDetectionService();

  Future<void> _detectHateSpeech() async {
    if (!_isEnglishSelected && !_isHinglishSelected) {
      setState(() {
        _result = 'Please select a language.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isEnglishSelected) {
        final id = await _englishTextDetectionService
            .getEnglishEventId(_textDataController.text);
        final result =
            await _englishTextDetectionService.getEnglishCompleteResult(id);
        if (result.contains("NEITHER")) {
          setState(() {
            _resultColor = Colors.green;
            _result = "The Statement is classified as normal speech";
          });
        } else {
          setState(() {
            _resultColor = Colors.red;
            _result = "The Statement is classified as hate speech";
          });
        }
      }

      if (_isHinglishSelected) {
        final id = await _hinglishTextDetectionService
            .getHinglishEventId(_textDataController.text);
        final result =
            await _hinglishTextDetectionService.getHinglishCompleteResult(id);

        String classificationMessage;
        Color resultColor;

        switch (result[0]) {
          case "OAG":
            classificationMessage =
                "The Statement is classified as overtly aggressive.";
            resultColor = Colors.red; // Overtly Aggressive
            break;
          case "CAG":
            classificationMessage =
                "The Statement is classified as covertly aggressive.";
            resultColor = Colors.red; // Covertly Aggressive
            break;
          case "NAG":
            classificationMessage =
                "The Statement is classified as not aggressive.";
            resultColor = Colors.green; // Not Aggressive
            break;
          default:
            classificationMessage = "Unknown classification.";
            resultColor = Colors.grey; // Unknown
            break;
        }

        setState(() {
          _result = classificationMessage;
          _resultColor = resultColor; // Add this line
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: ${e.toString()}';
        _resultColor = Colors.red; // Error color
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
                    checkmarkColor: Colors.white,
                    selected: _isEnglishSelected,
                    selectedColor: Colors.blue,
                    label: const Text('English'),
                    onSelected: (bool selected) {
                      setState(() {
                        _isEnglishSelected = selected;
                        if (selected) {
                          _isHinglishSelected = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  FilterChip(
                    labelStyle: TextStyle(
                      color: _isHinglishSelected
                          ? Colors.white
                          : const Color.fromARGB(255, 2, 141, 255),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    checkmarkColor: Colors.white,
                    selected: _isHinglishSelected,
                    selectedColor: Colors.blue,
                    label: const Text('Hinglish'),
                    onSelected: (bool selected) {
                      setState(() {
                        _isHinglishSelected = selected;
                        if (selected) {
                          _isEnglishSelected = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 10),
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
                onPressed: _isLoading
                    ? null
                    : () {
                        FocusScope.of(context).unfocus();
                        _detectHateSpeech();
                      },
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  backgroundColor:
                      WidgetStateProperty.all<Color>(primaryColor),
                  foregroundColor:
                      WidgetStateProperty.all<Color>(Colors.black),
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
                        color: _resultColor,
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
